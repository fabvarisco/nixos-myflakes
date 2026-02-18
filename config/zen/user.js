// Zen Browser User Preferences

// Enable userChrome.css and userContent.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Homepage and new tab settings
user_pref("browser.startup.homepage", "file:///home/fabvarisco/.local/share/zen-startpage/index.html");
user_pref("browser.startup.page", 1);
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtab.url", "file:///home/fabvarisco/.local/share/zen-startpage/index.html");

// Disable default Firefox home and override behaviors
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("browser.startup.firstrunSkipsHomepage", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.startup.homepage_welcome_url", "");
user_pref("browser.startup.homepage_welcome_url.additional", "");

// Zen-specific startup settings
user_pref("zen.welcome-screen.seen", true);
user_pref("zen.startup.page", "homepage");

// PywalZen configuration - required for theme to work
user_pref("uc.pywalzen.darkness", "dark");
