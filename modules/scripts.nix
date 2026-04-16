{ ... }:

{
  home.file = {
    ".local/bin/llvm-session"         = { source = ../scripts/llvm-session;         executable = true; };
    ".local/bin/map"                  = { source = ../scripts/map;                  executable = true; };
    ".local/bin/open-github"          = { source = ../scripts/open-github;          executable = true; };
    ".local/bin/resume-update"        = { source = ../scripts/resume-update;        executable = true; };
    ".local/bin/tmux-rename-session"  = { source = ../scripts/tmux-rename-session;  executable = true; };
    ".local/bin/tmux-session-picker"  = { source = ../scripts/tmux-session-picker;  executable = true; };
    ".local/bin/website-notes-update" = { source = ../scripts/website-notes-update; executable = true; };
    ".local/bin/wts"                  = { source = ../scripts/wts;                  executable = true; };
  };
}
