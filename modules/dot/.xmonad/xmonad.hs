{-# LANGUAGE LambdaCase       #-}
{-# LANGUAGE TypeApplications #-}

import           Control.Monad               (forM_)
import           Data.Bool                   (bool)
import           Data.List
import qualified Data.Map                    as M
import           Data.Monoid
import           System.IO
import           XMonad
import           XMonad.Actions.GridSelect
import           XMonad.Actions.Volume
import           XMonad.Actions.ShowText
import           XMonad.Config.Kde
import           XMonad.Hooks.DynamicHooks
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.FadeInactive
import           XMonad.Hooks.FadeWindows    (fadeWindowsLogHook, opaque,
                                              transparency, transparent, Opacity)
import           XMonad.Hooks.ManageDocks    hiding (L)
import           XMonad.Hooks.ManageHelpers (doRectFloat)
import           XMonad.Hooks.Script
import           XMonad.Layout
import           XMonad.Layout.Grid
import           XMonad.Layout.NoBorders     (noBorders, smartBorders)
import           XMonad.Layout.PerWorkspace
import           XMonad.Layout.Tabbed
import           XMonad.Layout.WorkspaceDir
import           XMonad.Prompt
import           XMonad.Prompt.Shell
import           XMonad.Prompt.XMonad
import qualified XMonad.StackSet             as W
import qualified XMonad.Util.ExtensibleState as XS
import           XMonad.Util.EZConfig        (additionalKeys, additionalKeysP)
import           XMonad.Util.Run             (runInTerm, safeSpawn, spawnPipe, unsafeSpawn, runProcessWithInput)
import           XMonad.Util.Brightness      (increase, decrease)

import           XMonad.Config (def)
import           XMonad.Config.Desktop
import           XMonad.Hooks.UrgencyHook
import           XMonad.Actions.CycleWS (nextWS, shiftToNext, nextScreen, shiftNextScreen)
import XMonad.StackSet(RationalRect(..))
import Data.Ratio((%))
import XMonad.Actions.UpdateFocus
import Control.Monad(void)
import System.IO.Unsafe(unsafePerformIO)
import Control.Concurrent(threadDelay)

getDisplays :: X [String]
getDisplays = fmap (fmap (head . words) . lines)
            $ runProcessWithInput "xrandr" [] "" >>= runProcessWithInput "grep" [" connected"]

disp p s dType | dType == DS0 = p
                 | otherwise = s

other p s dType | dType == DS0 = s
                | otherwise = p

data DisplayState = DS0
                  -- | DS1
                  | DSBoth deriving (Eq, Bounded, Enum, Show, Typeable)
instance ExtensionClass DisplayState where
    initialValue = DS0

-- Cyclic enumeration hack
next :: (Eq a, Enum a, Bounded a) => a -> a
next = bool minBound <$> succ <*> (/= maxBound)


myTallLayout =  Tall nmaster delta ratio
    where
    nmaster = 1
    delta = 10/100
    ratio = toRational (2/(1+sqrt 5::Double))

myDefaultLayout =
        simpleTabbed
    ||| smartBorders myTallLayout

myLayout = avoidStruts myDefaultLayout

spawnShell = safeSpawn myTerminal []

restartXMonad = broadcastMessage ReleaseResources >>
                restart "xmonad" True

audioInc = void (raiseVolume 4)
audioDec = void (lowerVolume 4)
audioMute = void toggleMute

-- sndDisplayPos = "--right-of"
-- sndDisplayPos = "--left-of"
sndDisplayPos = "--above"
-- sndDisplayPos = "--below"

xrandrSingle dType = do
  ds <- getDisplays
  case ds of
    [p, s] -> do
      safeSpawn "xrandr" [ "--dpi","110"
                         , "--output", disp p s dType,   "--auto"
                         , "--output", other p s dType, "--off"
                         ]

    _ -> do
      safeSpawn "xrandr" []


xrandrBoth = do
  ds <- getDisplays
  case ds of
    [p, s] -> do
      safeSpawn "xrandr" [ "--dpi","110"
                         , "--output", p, "--auto"
                         , sndDisplayPos , s
                         , "--output", s, "--auto"

                         ] -- , "--rotate", "left"]
    _ -> do
      safeSpawn "xrandr" []

logger :: String -> IO ()
logger msg = do
    h <- openFile "/var/log/xmonad.log" AppendMode
    hPutStrLn h msg
    hClose h

myKeys conf = M.fromList $
    [ ((0, xK_Print),  safeSpawn "scrot" [ "~/downloads/screenshots/%y-%b%d-%H:%M:%S.png"] )

    -- Toggle primary display
    , ( (mod4Mask , xK_r)
      ,  XS.modify @DisplayState next
      >> XS.get @DisplayState >>= \case
          DS0   -> xrandrSingle DS0
          -- DS1 -> xrandrSingle DS1
          DSBoth      -> xrandrBoth
      )


    -- Mouse keys
    , ((mod4Mask , xK_t), safeSpawn "xrandr-invert-colors" [])

    -- X windows control
    , ((mod4Mask .|. shiftMask, xK_comma), sendMessage Shrink )
    , ((mod4Mask .|. shiftMask, xK_period), sendMessage Expand )
    , ((mod4Mask , xK_comma ), sendMessage (IncMasterN 1))
    , ((mod4Mask , xK_period), sendMessage (IncMasterN (-1)))

    , ((mod4Mask , xK_k), safeSpawn "pkill" ["spotify"] )
    , ((mod4Mask , xK_s), safeSpawn "spotify" [])

    -- Windows management is moved to tmux so use tmux's modifier for window specific actions on xmonad level
    , ((mod1Mask , xK_Tab), windows W.focusDown)
    , ((mod1Mask .|. shiftMask, xK_Tab), windows W.swapDown)
    , ((mod1Mask , xK_p), shellPrompt $ amberXPConfig { font = "xft:Hack:pixelsize=24", height = 30 })
    , ((mod1Mask , xK_semicolon), safeSpawn "rofi" ["-modi", "run", "-show", "drun"])
    , ((mod1Mask, xK_Return), spawnShell)
    , ((mod1Mask, xK_Left), audioDec)
    , ((mod1Mask, xK_Right), audioInc)
    , ((mod1Mask, xK_q), restartXMonad)
    , ((mod1Mask, xK_space), sendMessage NextLayout)
    , ((mod1Mask, xK_t), withFocused $ windows . W.sink) -- %! Push window back into tiling
    , ((mod1Mask, xK_quoteleft),  nextScreen)
    , ((mod1Mask .|. shiftMask, xK_quoteleft), shiftToNext)
    ]
    <>
    -- mod-{w,e} %! Switch to physical/Xinerama screens 1 or 2
    -- mod-shift-{w,e} %! Move client to screen 1 or 2
    [ ((m .|. mod4Mask, key), screenWorkspace sc >>= flip whenJust (windows . f))
    | (key, sc) <- zip [xK_w, xK_e] (bool [0, 1] [1, 0] (sndDisplayPos `elem` ["right-of", "above"]))
    , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    -- <>
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    <>
    [((m .|. mod4Mask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

myAdditionalKeysP =
    [ ("<XF86MonBrightnessUp>", unsafeSpawn "for d in $(xrandr --listmonitors | tail -n +2  | awk '{print $2}' | tr -d '+*'); do; xrandr --output $d --brightness 1; done")
    , ("<XF86MonBrightnessDown>", unsafeSpawn "for d in $(xrandr --listmonitors | tail -n +2  | awk '{print $2}' | tr -d '+*'); do; xrandr --output $d --brightness 0.2; done")
    , ("<XF86AudioMute>", audioMute)
    , ("<XF86AudioLowerVolume>", audioDec)
    , ("<XF86AudioPrev>", audioDec)
    , ("<XF86AudioRaiseVolume>", audioInc)
    , ("<XF86AudioNext>", audioInc)
    , ("<XF86AudioPlay>", safeSpawn "pavucontrol-qt" [])
    ]

myLogHookFade :: X ()
myLogHookFade = fadeInactiveLogHook 0.6

myStartupHook = do
  spawn "feh --bg-fill --no-fehbg ~/.wallpaper"

myConfig h = kdeConfig
    { manageHook = manageDocks <+> manageHook def
                               <+> composeAll
                                   [ className =? "qjackctl"      --> doFloat]
                               <+> doRectFloat (RationalRect (1%32) (1%16) (1%2) (3%8))
    , logHook = myLogHookFade
    , layoutHook =  myLayout
    , handleEventHook = mconcat [ handleEventHook def]
    , modMask = mod4Mask
    , terminal = myTerminal
    , borderWidth = 1
    , focusFollowsMouse = False
    , workspaces = myWorkspaces
    , keys = myKeys
    , startupHook = myStartupHook
    } `additionalKeysP` myAdditionalKeysP

main = do
    xmbH <- spawnPipe "source /home/vcanadi/.xmonad/.xmobarrc.sh"
    xmonad $ myConfig xmbH

myTerminal = "terminator"
myWorkspaces = ["w1", "w2"]  -- Force usage of tmux as a window manager by restricting control on xmonad layer
