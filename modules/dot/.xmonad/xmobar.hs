Config {


   -- appearance
     font =         "Ubuntu 14"
   , additionalFonts =
     [ "Font Awesome 66 Free Solid 14"
     , "Mononoki 14"
     ]
   , bgColor =      "black"
   , fgColor =      "#AAAAAA"
   , position =     BottomSize C 100 40
   , border =       TopB
   , borderColor =  "#646464"

   -- layout
   , sepChar =  "%"   -- delineator between plugin names and straight text
   , alignSep = "}{"  -- separator between left-right alignment
   , template = "%disku%  |  %diskio% | %multicpu%  |  %top% | 📺 %gput%  |  %memory%  |  %topmem%   }{  %dynnetwork%  |  %battery%  |  %date%  |  %kbd%   "

   -- general behavior
   , lowerOnStart =     True    -- send to bottom of window stack on start
   , hideOnStart =      False   -- start with window unmapped (hidden)
   , allDesktops =      True    -- show on all desktops
   , overrideRedirect = False    -- set the Override Redirect flag (Xlib)
   , pickBroadest =     True    -- choose widest display (multi-monitor)
   , persistent =       True    -- enable/disable hiding (True = disabled)
   , commands =
        [ Run DiskU
            [("/", "💾 <used>/<size>"), ("sdb3", "<usedvbar>")]
            ["-L", "20", "-H", "50", "-m", "1", "-p", "3"]
            100

        , Run DiskIO
            [("/", "💾 <read> <write>"), ("sdb3", "<total>")]
            []
            50

        , Run TopProc
           [ "--template" , "^🧠 <both1> %"
           ] 50

        , Run TopMem
           [ "--template" , "^🐏 <both1>  "
           ] 50

        -- cpu activity monitor
        , Run MultiCpu
            [ "--template" , "🧠 <autototal> % "
            , "--Low"      , "50"         -- units: %
            , "--High"     , "85"         -- units: %
            , "--low"      , "darkgreen"
            , "--normal"   , "darkorange"
            , "--high"     , "darkred"
            ] 30

        -- memory usage monitor
        , Run Memory
            [ "--template" ,"🐏 <usedratio> %"
            , "--Low"      , "20"        -- units: %
            , "--High"     , "90"        -- units: %
            , "--low"      , "darkgreen"
            , "--normal"   , "darkorange"
            , "--high"     , "darkred"
            ] 30

        -- network activity monitor (dynamic interface resolution)
        , Run DynNetwork
            [ "--template" , "ᯤ <dev>: <tx>kB/s|<rx>kB/s"
            , "--Low"      , "1000"       -- units: kB/s
            , "--High"     , "5000"       -- units: kB/s
            , "--low"      , "darkgreen"
            , "--normal"   , "darkorange"
            , "--high"     , "darkred"
            ] 50


        -- battery monitor
        , Run Battery        [ "--template" , "🔋 <acstatus>"
                             , "--Low"      , "10"        -- units: %
                             , "--High"     , "80"        -- units: %
                             , "--low"      , "darkred"
                             , "--normal"   , "darkorange"
                             , "--high"     , "darkgreen"

                             , "--" -- battery specific options
                                       -- discharging status
                                       , "-o"	, "<left>% (<timeleft>)"
                                       -- AC "on" status
                                       , "-O"	, "<fc=#dAA520>Charging</fc>"
                                       -- charged status
                                       , "-i"	, "<fc=#006000>Charged</fc>"
                             ] 50
        -- time and date indicator
        , Run Date           "<fc=#ABABAB>%b %d %a %T</fc>" "date" 10

        -- , Run XMonadLog

        -- keyboard layout indicator
        , Run Kbd
            [ ("hr2" , "<fc=#008B00>⌨ HR</fc>")
            , ("us2" , "<fc=#8B0000>⌨ US</fc>")
            ]
        , Run Com "nvidia-smi" ["--query-gpu=power.draw", "--format=csv,noheader"] "gput" 50
        ]
   }
