import subprocess
import os
from qutebrowser.api import interceptor

def filter_yt(info: interceptor.Request):
    """Block the given request if necessary."""
    url = info.request_url
    if (
        url.host() == "www.youtube.com"
        and url.path() == "/get_video_info"
        and "&adformat=" in url.query()
    ):
        info.block()

interceptor.register(filter_yt)
c.search.incremental = False
c.session.lazy_restore = True
c.qt.highdpi = True
c.auto_save.session = True
config.set('content.headers.user_agent',
           'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36',
           '*')
config.set('content.images', True, 'chrome-devtools://*')
config.set('content.images', True, 'devtools://*')
c.content.javascript.can_open_tabs_automatically = False
c.content.notifications.enabled = True
c.content.desktop_capture = True
config.set('content.javascript.enabled', True, 'file://*')
config.set('content.javascript.enabled', True, 'chrome-devtools://*')
config.set('content.javascript.enabled', True, 'devtools://*')
config.set('content.javascript.enabled', True, 'chrome://*/*')
config.set('content.javascript.enabled', True, 'qute://*/*')
config.set('content.blocking.enabled', True)
config.set('content.blocking.method', 'both')
c.content.cookies.accept = 'all'
c.content.prefers_reduced_motion = True

c.content.media.audio_capture = True
c.content.plugins = True
c.content.proxy = 'system'
c.content.pdfjs = True
c.completion.height = '50%'
c.completion.quick = True
c.downloads.location.directory = '~/downloads'
c.downloads.remove_finished = 2
c.hints.auto_follow = 'never'
c.hints.chars = 'asdfghjkl'
c.hints.hide_unmatched_rapid_hints = True
c.hints.mode = 'number'
c.hints.scatter = False
c.hints.uppercase = False
c.scrolling.bar = 'always'
c.spellcheck.languages = ['en-US', 'hr-HR']
c.statusbar.position = 'top'
c.tabs.background = False
c.tabs.favicons.scale = 1
c.tabs.mousewheel_switching = False
c.tabs.position = 'top'
c.tabs.select_on_remove = 'prev'
c.tabs.show = 'always'
c.tabs.title.format = '{index}: {current_title}'
c.tabs.width = '15%'
c.tabs.padding = {'bottom': 10, 'left': 5, 'right': 5, 'top': 10}
c.url.default_page = 'www.startpage.com'
c.url.searchengines = {'DEFAULT': 'https://google.com/search?q={}'}
# c.url.searchengines = {'DEFAULT': 'https://duckduckgo.com/?q={}'}
c.zoom.default = '90%'
c.colors.completion.fg = ['white', 'white', 'white']
c.colors.completion.odd.bg = '#00444444'
c.colors.completion.even.bg = '#D0333333'
c.colors.completion.category.bg = 'qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #22888888, stop:1 #22505050)'
c.colors.hints.fg = 'black'
c.colors.hints.bg = 'qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 rgba(0,255, 0, 0.8), stop:1 rgba(0,255, 0, 0.2))'
c.colors.hints.match.fg = 'red'
# c.colors.tabs.bar.bg = '#EEEEEE'
# c.colors.tabs.odd.bg = '#EEEEEE'
# c.colors.tabs.even.bg = '#EEEEEE'
c.colors.tabs.bar.bg = 'white'
c.colors.tabs.odd.fg = 'black'
c.colors.tabs.odd.bg = 'white'
c.colors.tabs.even.fg = 'black'
c.colors.tabs.even.bg = 'white'
c.colors.tabs.selected.odd.fg = 'white'
c.colors.tabs.selected.odd.bg = 'black'
c.colors.tabs.selected.even.fg = 'white'
c.colors.tabs.selected.even.bg = 'black'
c.colors.tabs.pinned.odd.fg = 'black'
c.colors.tabs.pinned.odd.bg = 'white'
c.colors.tabs.pinned.even.fg = 'black'
c.colors.tabs.pinned.even.bg = 'white'
c.colors.tabs.pinned.selected.odd.fg = 'white'
c.colors.tabs.pinned.selected.odd.bg = 'black'
c.colors.tabs.pinned.selected.even.fg = 'white'
c.colors.tabs.pinned.selected.even.bg = 'black'
c.fonts.completion.entry = '16pt monospace'
c.fonts.completion.category = 'bold 16pt monospace'
c.fonts.debug_console = '16pt monospace'
c.fonts.hints = '14pt monospace'
c.fonts.messages.error = '20pt monospace'
c.fonts.statusbar = '16pt monospace'
c.fonts.web.size.minimum = 0
c.fonts.web.size.minimum_logical = 6

# Bindings for normal mode
config.bind('<Alt+b>', 'cmd-set-text -s :quickmark-load -t')
config.bind('<Alt+h>', 'back')
config.bind('<Alt+j>', 'tab-next')
config.bind('<Alt+k>', 'tab-prev')
config.bind('<Alt+l>', 'forward')
config.bind('<Alt+n>', 'cmd-set-text -s :open -t')
config.bind('<Alt+m>', 'cmd-set-text -s :open -t hackage')
config.bind('<Ctrl+Shift+y>', 'hint links spawn --detach mpv --force-window yes {hint-url}')
config.bind('<Alt+w>', 'tab-close')
config.bind('<Ctrl+w>', 'None')
config.bind('B', 'None')
config.bind('H', 'None')
config.bind('J', 'None')
config.bind('K', 'None')
config.bind('L', 'None')
config.bind('M', 'None')
config.bind('O', 'None')
config.bind('P', 'open --private')
config.bind('d', 'None')
config.bind('e', 'move-to-end-of-word')
config.bind('gi', 'hint inputs')

config.bind('m', 'spawn mpv {url}')
config.bind('M', 'hint links spawn mpv {hint-url}')
config.load_autoconfig(False)

