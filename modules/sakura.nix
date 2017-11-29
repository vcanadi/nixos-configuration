let b = builtins; in
rec {
  userActivationScript = user:  ''
    cd ${user.home}/.config 
    if [ -d sakura ]; then rm sakura -r; fi 
    mkdir sakura 
    cp ${b.toFile "" conf} sakura/sakura.conf  
    chown ${user.name}:nogroup sakura -R
  '';
  conf = ''
    [sakura]
    forecolor=#000000
    backcolor=#ffffff
    backalpha=65535
    opacity_level=80
    fake_transparency=No
    background=none
    font=Inconsolata 12
    show_always_first_tab=No
    scrollbar=false
    closebutton=false
    audible_bell=Yes
    visible_bell=Yes
    blinking_cursor=No
    borderless=Yes
    maximized=No
    word_chars=-A-Za-z0-9,./?%&#_~
    palette=linux
    add_tab_accelerator=5
    del_tab_accelerator=5
    switch_tab_accelerator=8
    copy_accelerator=5
    scrollbar_accelerator=5
    open_url_accelerator=5
    add_tab_key=T
    del_tab_key=W
    prev_tab_key=Left
    next_tab_key=Right
    new_window_key=N
    copy_key=C
    paste_key=V
    scrollbar_key=S
    fullscreen_key=F11
  '';
}
