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
import System.IO (hPutStrLn)

sysCat t = void $ runProcessWithInput "systemd-cat"
  [ "echo"
  , "______________________________________\n"
  , "[XMonad Log] " <> t <> "\n"
  ] ""

main = do
  sysCat "Xmonad started"
  xmproc <- spawnPipe "pkill xmobar; sleep 0.2; source /home/vcanadi/.xmonad/.xmobarrc.sh"
  xmonad $ ewmhFullscreen $ ewmh $ xmobarProp $ myConfig xmproc

getDisplays :: X [String]
getDisplays = do
  displays <- fmap (fmap (head . words) . lines)
   $ (runProcessWithInput "xrandr" [] "")
     >>= runProcessWithInput "grep" [" connected"]
  sysCat $ "getDisplays::displays: " <> show displays
  pure displays

data DisplayState = DS0
                  | DS1
                  | DSBoth deriving (Eq, Bounded, Enum, Show, Typeable)
instance ExtensionClass DisplayState where
  initialValue = DS0

newtype BrightnessState = BrightnessState { brightnessValue :: Float} deriving (Eq, Show)
instance ExtensionClass BrightnessState where
  initialValue = BrightnessState 1

-- Cyclic enumeration
nextEnm' :: (Eq a, Enum a, Bounded a) => a -> a
nextEnm' = bool minBound <$> succ <*> (/= maxBound)

-- Enumeration with upper limit
nextEnm :: (Eq a, Enum a, Bounded a) => a -> a
nextEnm = bool maxBound <$> succ <*> (/= maxBound)

-- Reverse enumeration with lower limit
prevEnm :: (Eq a, Enum a, Bounded a) => a -> a
prevEnm = bool minBound <$> pred <*> (/= minBound)

myLayout = avoidStruts
         $ simpleTabbed
       ||| smartBorders (Tall nmaster delta ratio)
  where
    nmaster = 1
    delta = 10/100
    ratio = toRational (2/(1+sqrt 5::Double))

-- | Hardcode relative location of secondary screen
-- sndDisplayPos = "--right-of"
-- sndDisplayPos = "--left-of"
sndDisplayPos = "--above"
-- sndDisplayPos = "--below"

-- | Show only on single display
xrandrSingle dType = getDisplays >>=
  \case
    [p, s] -> do
      let args = [ "--dpi","110", "--output", disp p s dType, "--auto", "--output", other p s dType, "--off" ]
      sysCat $ "xrandSingle::xrand args: " <> unwords args
      safeSpawn "xrandr" args
    [p]    -> do
      let args = [ "--dpi","110", "--output", p, "--auto"]
      sysCat $ "xrandSingle::xrand args: " <> unwords args
      safeSpawn "xrandr" args
    _      -> return ()
  where
    disp p s dType = if dType == DS0 then p else s
    other p s dType = if dType == DS0 then s else p

-- | Show on two displays
xrandrBoth = (sysCat "Both displays") >> getDisplays >>=
  \case
    [p, s] -> do
      let args = [ "--dpi","110", "--output", p, "--auto", sndDisplayPos , s, "--output", s, "--auto"]
      sysCat $ "xrandSingle::xrand args: " <> unwords args
      safeSpawn "xrandr" args
    [p]    -> do
      let args = [ "--dpi","110", "--output", p, "--auto" ]
      sysCat $ "xrandSingle::xrand args: " <> unwords args
      safeSpawn "xrandr" args
    _      ->  return ()

myConfig xmproc = def
    { layoutHook =  myLayout
    , terminal = myTerminal
    , borderWidth = 20
    , normalBorderColor = "black"
    , focusedBorderColor = "#009900"
    , focusFollowsMouse = False
    , keys = myKeys
    , startupHook = sysCat "Xmonad startup hook"
    -- , logHook = dynamicLogWithPP xmobarPP
    --       { ppOutput          = hPutStrLn xmproc
    --       , ppTitle           = xmobarColor "darkgreen"  "" . shorten 20
    --       , ppHiddenNoWindows = xmobarColor "grey" ""
    --       }
    } `additionalKeysP` myAdditionalKeysP
  where

  myKeys conf = M.fromList $
      [ ((0, xK_Print),  safeSpawn "scrot" [ "~/downloads/screenshots/%y-%b%d-%H:%M:%S.png"] )

      -- | Toggle primary display
      , ( (mod4Mask , xK_r)
        ,  XS.modify @DisplayState nextEnm' -- ^ Toggle between display states (e.g. show on primary display, show on secondary display, show on both displays (extend))
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
      [ ("<XF86MonBrightnessUp>"             -- ^ Increase brightness on all screens
        , do
          XS.modify @BrightnessState brightnessInc -- ^ Toggle up between brightness levels
          b <- XS.get @BrightnessState
          getDisplays >>= mapM_ (brightnessSet b)
        )
      , ("<XF86MonBrightnessDown>"           -- ^ Decrease brightness on all screens
        , do
          XS.modify @BrightnessState brightnessDec -- ^ Toggle down between brightness levels
          b <- XS.get @BrightnessState
          getDisplays >>= mapM_ (brightnessSet b)
        )
      , ("<XF86AudioMute>", audioMute)
      , ("<XF86AudioLowerVolume>", audioDec)               -- ^ Decrease audio volume
      , ("<XF86AudioRaiseVolume>", audioInc)               -- ^ Increase audio volume
      , ("<XF86AudioPlay>", safeSpawn "pavucontrol-qt" []) -- ^ Audio controls
      ]
    where
      audioInc = void (raiseVolume 4)
      audioDec = void (lowerVolume 4)
      audioMute = void toggleMute
      brightnessSet b d = unsafeSpawn $ "xrandr --output " <> d <> " --brightness " <> show (brightnessValue b)
      brightnessInc (BrightnessState f) = BrightnessState $ min (f + 0.05) 1
      brightnessDec (BrightnessState f) = BrightnessState $ max (f - 0.05) 0.1

  myTerminal = "terminator"
