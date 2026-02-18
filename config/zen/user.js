// Zen Browser User Preferences

// Enable userChrome.css and userContent.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Homepage and new tab settings
user_pref("browser.startup.homepage", "file:///home/fabvarisco/.local/share/zen-startpage/index.html");
user_pref("browser.startup.page", 1);
user_pref("browser.newtabpage.enabled", false);

// Disable default Firefox home
user_pref("browser.startup.homepage_override.mstone", "ignore");
