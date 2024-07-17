{-# LANGUAGE LambdaCase       #-}
{-# LANGUAGE TypeApplications #-}

import XMonad
import           Control.Monad               (forM_)
import           Data.Bool                   (bool)
import qualified Data.Map                    as M
import           XMonad.Actions.Volume
import           XMonad.Hooks.FadeInactive
import           XMonad.Hooks.ManageDocks    hiding (L)
import           XMonad.Layout.NoBorders     (noBorders, smartBorders)
import           XMonad.Layout.Tabbed
import           XMonad.Prompt (font, height, amberXPConfig)
import           XMonad.Prompt.Shell (shellPrompt)
import qualified XMonad.StackSet             as W
import qualified XMonad.Util.ExtensibleState as XS
import           XMonad.Util.EZConfig        (additionalKeys, additionalKeysP)
import           XMonad.Util.Run             (runInTerm, safeSpawn, spawnPipe, unsafeSpawn, runProcessWithInput)
import           XMonad.Actions.CycleWS (nextWS, shiftToNext, nextScreen, shiftNextScreen)
import           XMonad.StackSet(RationalRect(..))
import           Data.Ratio((%))
import           Control.Monad(void)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog

systemdCat t = void $ runProcessWithInput "systemd-cat"
  [ "echo"
  , "______________________________________\n"
  , "[XMonad Log] " <> t <> "\n"
  ] ""

main = do
  systemdCat "Xmonad started"
  xmonad $ ewmhFullscreen $ ewmh $ xmobarProp $ myConfig -- xmbH

getDisplays :: X [String]
getDisplays = fmap (fmap (head . words) . lines)
            $ runProcessWithInput "xrandr" [] "" >>= runProcessWithInput "grep" [" connected"]

data DisplayState = DS0
                  | DS1
                  | DSBoth deriving (Eq, Bounded, Enum, Show, Typeable)
instance ExtensionClass DisplayState where
    initialValue = DS0

-- Cyclic enumeration hack
next :: (Eq a, Enum a, Bounded a) => a -> a
next = bool minBound <$> succ <*> (/= maxBound)

myLayout = avoidStruts
         $ simpleTabbed
       ||| smartBorders (Tall nmaster delta ratio)
  where
    nmaster = 1
    delta = 10/100
    ratio = toRational (2/(1+sqrt 5::Double))

-- | Hardcode relative location of secondary screen
sndDisplayPos = "--right-of"
-- sndDisplayPos = "--left-of"
-- sndDisplayPos = "--above"
-- sndDisplayPos = "--below"

-- | Show only on single display
xrandrSingle dType = getDisplays >>=
  \case
    [p, s] -> safeSpawn "xrandr" [ "--dpi","110", "--output", disp p s dType, "--auto", "--output", other p s dType, "--off" ]
    [p]    -> safeSpawn "xrandr" [ "--dpi","110", "--output", p, "--auto"]
    _      -> return ()
  where
    disp p s dType = if dType == DS0 then p else s
    other p s dType = if dType == DS0 then s else p

-- | Show on two displays
xrandrBoth = getDisplays >>=
  \case
    [p, s] ->  safeSpawn "xrandr" [ "--dpi","110", "--output", p, "--auto", sndDisplayPos , s, "--output", s, "--auto"]
    [p]    ->  safeSpawn "xrandr" [ "--dpi","110", "--output", p, "--auto" ]
    _      ->  return ()

myConfig = def
    { layoutHook =  myLayout
    , terminal = myTerminal
    , borderWidth = 1
    , focusFollowsMouse = False
    , keys = myKeys
    , startupHook = systemdCat "Xmonad startup hook"
                 >> void (spawnPipe "pkill xmobar; sleep 1; source /home/vcanadi/.xmonad/.xmobarrc.sh")
    } `additionalKeysP` myAdditionalKeysP
  where

  myKeys conf = M.fromList $
      [ ((0, xK_Print),  safeSpawn "scrot" [ "~/downloads/screenshots/%y-%b%d-%H:%M:%S.png"] )

      -- | Toggle primary display
      , ( (mod4Mask , xK_r)
        ,  XS.modify @DisplayState next -- ^ Toggle between display states (e.g. show on primary display, show on secondary display, show on both displays (extend))
        >> XS.get @DisplayState >>= \case -- ^ Based on display state, do the display selection
            DS0    -> xrandrSingle DS0
            DS1    -> xrandrSingle DS1
            DSBoth -> xrandrBoth
        )

      -- | Dark mode
      , ((mod4Mask , xK_t), safeSpawn "xrandr-invert-colors" [])

      -- X windows control
      , ((mod4Mask .|. shiftMask, xK_comma), sendMessage Shrink )                                        -- ^ Resize (dec) window in layout (e.g. in vertical, dec. left side)
      , ((mod4Mask .|. shiftMask, xK_period), sendMessage Expand )                                       -- ^ Resize (dec) window in layout (e.g. in vertical, dec. right side)
      , ((mod4Mask , xK_comma ), sendMessage (IncMasterN 1))                                             -- ^ Move windows within layout (e.g. in vertical layout, move to left side)
      , ((mod4Mask , xK_period), sendMessage (IncMasterN (-1)))                                          -- ^ Move windows within layout (e.g. in vertical layout, move to right side)

      --  | Windows management is moved to tmux so use tmux's modifier for window specific actions on xmonad level
      , ((mod1Mask , xK_Tab), windows W.focusDown)                                                       -- ^ Select next window
      , ((mod1Mask .|. shiftMask, xK_Tab), windows W.swapDown)                                           -- ^ Move window to next position
      , ((mod1Mask , xK_p), shellPrompt $ amberXPConfig { font = "xft:Hack:pixelsize=24", height = 40 }) -- ^ Spawn shell menu
      , ((mod1Mask , xK_semicolon), safeSpawn "rofi" ["-modi", "run", "-show", "drun"])                  -- ^ Spawn rofi
      , ((mod1Mask, xK_Return), safeSpawn myTerminal [])                                                 -- ^ Open new terminal window
      , ((mod1Mask, xK_q), broadcastMessage ReleaseResources >> restart "xmonad" True)                   -- ^ Reload xmonad
      , ((mod1Mask, xK_space), sendMessage NextLayout)                                                   -- ^ Select different layouts/views
      , ((mod1Mask, xK_t), withFocused $ windows . W.sink)                                               -- ^ Tile current(floating) window
      , ((mod1Mask, xK_quoteleft),  nextScreen)                                                          -- ^ Select next screens
      , ((mod1Mask .|. shiftMask, xK_quoteleft), shiftToNext)                                            -- ^ Move window to next screen
      ]
      <>
      -- | Select and move windows between workspaces 1-9
      [((m .|. mod4Mask, k), windows $ f w)
          | (w, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9] -- ^ Over workspace/keys 1-9
          , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]] -- ^ Over select/move action

  myAdditionalKeysP =
      [ ("<XF86MonBrightnessUp>"                           -- ^ Max brightness on all screens
        , getDisplays >>= (`forM_` (\d -> unsafeSpawn $ "xrandr --output " <> d <> " --brightness 1")) )
      , ("<XF86MonBrightnessDown>"                         -- ^ Dimmed brightness on all screens
        , getDisplays >>= (`forM_` (\d -> unsafeSpawn $ "xrandr --output " <> d <> " --brightness 0.3")))
      , ("<XF86AudioMute>", audioMute)
      , ("<XF86AudioLowerVolume>", audioDec)               -- ^ Decrease audio volume
      , ("<XF86AudioRaiseVolume>", audioInc)               -- ^ Increase audio volume
      , ("<XF86AudioPlay>", safeSpawn "pavucontrol-qt" []) -- ^ Audio controls
      ]
    where
      audioInc = void (raiseVolume 4)
      audioDec = void (lowerVolume 4)
      audioMute = void toggleMute

  myTerminal = "terminator"
