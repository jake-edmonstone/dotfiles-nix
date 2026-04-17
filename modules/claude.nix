{ config, lib, isCerebras, ... }:

{
  home.file = {
    ".claude/CLAUDE.md".text = ''
      ## Code Quality
      - Prefer correct, complete implementations over minimal ones.
      - Use appropriate data structures and algorithms — don't brute-force what has a known better solution.
      - When fixing a bug, fix the root cause, not the symptom.
      - If something I asked for requires error handling or validation to work reliably, include it without asking.
      ${lib.optionalString isCerebras ''- Prefer brace initialization `{}` over parenthesized initialization `()` in C++ for consistency.''}

      ## Thoroughness and Effort
      - Token spend, tool calls, and response time are NOT a concern. I will always wait for a correct, well-researched answer over a fast, shallow one. Take as long as you need.
      - NEVER speculate or state something as fact without verifying it first. If you're unsure, look it up — read the file, search the codebase, check the docs. Do not guess.
      - NEVER suggest that I make edits, run commands, or look something up when you could do it yourself. You have the tools — use them. The only exception is when something genuinely requires my interactive input (e.g., login, 2FA, GUI).
      - Do not take shortcuts to reduce tool calls or output length. If solving a problem correctly requires reading 10 files, read 10 files. If it requires running a build to verify, run the build.
      - When asked a question, research it thoroughly before answering. Read relevant source code, check documentation, and verify your claims against reality. A wrong answer delivered quickly is worse than a correct answer delivered slowly.
      - Proactively use WebSearch and WebFetch when the answer is likely to be found online — official docs, GitHub issues, Stack Overflow, changelogs, etc. Do not rely on training data alone when current information is available on the web.
      - Do not summarize or hand-wave over details to keep responses short. Be precise and complete.
    '';

    ".claude/settings.json".text = builtins.toJSON ({
      env = {
        CLAUDE_CODE_NO_FLICKER = "1";
        CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = "1";
        MAX_THINKING_TOKENS = "63999";
        CLAUDE_CODE_EFFORT_LEVEL = "max";
      };
      permissions = {
        allow = [
          "Read"
          "Glob"
          "Grep"
          "WebFetch"
          "WebSearch"

          # File/dir inspection
          "Bash(ls *)"
          "Bash(find *)"
          "Bash(tree *)"
          "Bash(stat *)"
          "Bash(file *)"
          "Bash(realpath *)"
          "Bash(readlink *)"
          "Bash(basename *)"
          "Bash(dirname *)"

          # Content reading
          "Bash(cat *)"
          "Bash(head *)"
          "Bash(tail *)"
          "Bash(wc *)"
          "Bash(grep *)"
          "Bash(rg *)"

          # Navigation (cd between segments is common in compound commands)
          "Bash(cd *)"
          "Bash(pwd)"

          # System info
          "Bash(whoami)"
          "Bash(id)"
          "Bash(id *)"
          "Bash(hostname)"
          "Bash(hostname *)"
          "Bash(uname *)"
          "Bash(date)"
          "Bash(date *)"
          "Bash(uptime)"
          "Bash(groups)"
          "Bash(groups *)"

          # Environment / shell introspection
          "Bash(env)"
          "Bash(printenv *)"
          "Bash(which *)"
          "Bash(type *)"
          "Bash(command -v *)"
          "Bash(echo *)"

          # System state (read-only)
          "Bash(ps *)"
          "Bash(df *)"
          "Bash(du *)"

          # Text transform (output only)
          "Bash(diff *)"
          "Bash(sort *)"
          "Bash(uniq *)"
          "Bash(cut *)"
          "Bash(tr *)"
          "Bash(column *)"
          "Bash(jq *)"

          # Git (read-only)
          "Bash(git status*)"
          "Bash(git log*)"
          "Bash(git diff*)"
          "Bash(git branch*)"
          "Bash(git remote*)"
          "Bash(git rev-parse*)"
          "Bash(git show*)"
          "Bash(git blame*)"
          "Bash(git ls-files*)"
          "Bash(git ls-tree*)"
          "Bash(git ls-remote*)"
          "Bash(git describe*)"
          "Bash(git config --get*)"
          "Bash(git config --list*)"
          "Bash(git config -l*)"
          "Bash(git worktree list*)"
          "Bash(git stash list*)"
          "Bash(git stash show*)"
          "Bash(git tag --list*)"
          "Bash(git tag -l*)"

          # Nix (read-only)
          "Bash(nix eval *)"
          "Bash(nix flake show*)"
          "Bash(nix flake metadata*)"
          "Bash(nix flake check*)"
          "Bash(nix derivation show*)"
          "Bash(nix show-derivation*)"
          "Bash(nix search *)"
          "Bash(nix-instantiate --eval*)"
          "Bash(nix-instantiate --parse*)"

          # gh (read-only)
          "Bash(gh pr view*)"
          "Bash(gh pr list*)"
          "Bash(gh pr diff*)"
          "Bash(gh pr checks*)"
          "Bash(gh issue view*)"
          "Bash(gh issue list*)"
          "Bash(gh repo view*)"
          "Bash(gh run view*)"
          "Bash(gh run list*)"

          # Network fetches (curl -s is flag-locked to silent, no -o to write files)
          "Bash(curl -s *)"
        ];
        defaultMode = "default";
      };
      model = "opus[1m]";
      hooks = {
        Notification = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "printf '\\a'";
              }
            ];
          }
        ];
      };
      enabledPlugins = {
        "lua-lsp@claude-plugins-official" = true;
        "pyright-lsp@claude-plugins-official" = true;
      };
      skipAutoPermissionPrompt = true;
      statusLine = {
        type = "command";
        command = "bash ${config.home.homeDirectory}/.claude/statusline.sh";
      };
    } // lib.optionalAttrs isCerebras {
      claudeMdExcludes = [
        "/net/*"
        "/net/*/*/"
      ];
    });

    ".claude/statusline.sh" = { source = ../claude/statusline.sh; executable = true; };

    # Agents and skills — auto-picked up from the repo directories, so adding
    # a new one just means dropping it in ../claude/agents or ../claude/skills
    ".claude/agents" = { source = ../claude/agents; recursive = true; };
    ".claude/skills" = { source = ../claude/skills; recursive = true; };
  };
}
