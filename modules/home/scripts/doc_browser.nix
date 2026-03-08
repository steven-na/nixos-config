{ pkgs, ... }:

{
    home.file.".local/bin/doc-browser.sh" = {
        force = true;
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env bash
                # doc-browser.sh — hierarchical documentation browser
                # Lives in special workspace: docs

                set -eu

                SCRIPT="$HOME/.local/bin/doc-browser.sh"

                if [ "$#" -eq 0 ] || [ "$1" != "--inner" ]; then
                  if ! pgrep -f "foot.*--app-id doc-browser" > /dev/null 2>&1; then
                    foot --app-id doc-browser -e bash "$SCRIPT" --inner &
                  fi
                  exit 0
                fi

                # ── Helpers ────────────────────────────────────────────────────────────────────

                fzf_menu() {
                  local prompt="$1"
                  local preview=""
                  if [ "$#" -ge 2 ]; then preview="$2"; fi

                  if [ -n "$preview" ]; then
                    fzf --prompt="$prompt " \
                        --height=100% \
                        --layout=reverse \
                        --no-border \
                        --no-info \
                        --preview="$preview" \
                        --preview-window='right,60%,wrap' \
                        --bind='esc:abort'
                  else
                    fzf --prompt="$prompt " \
                        --height=100% \
                        --layout=reverse \
                        --no-border \
                        --no-info \
                        --bind='esc:abort'
                  fi
                }

                is_back() {
                  [ "$1" = "<-- back" ]
                }

                BACK="<-- back"

                # ── MAN ────────────────────────────────────────────────────────────────────────

                menu_man() {
                  while true; do
                    choice=$(printf '%s\n' \
                      "$BACK" \
                      "Browse all sections" \
                      "Search by keyword (apropos)" \
                      "Direct name search" \
                      | fzf_menu "man >") || return

                    is_back "$choice" && return

                    case "$choice" in

                      "Browse all sections")
                        while true; do
                          entry=$(man -k . 2>/dev/null \
                            | sort \
                            | fzf_menu "man > browse >" \
                                'echo {} | sed "s/ (.*//" | xargs -I% sh -c "man -P cat % 2>/dev/null | head -80"' \
                            ) || break
                          is_back "$entry" && break
                          name=$(echo "$entry" | awk '{print $1}')
                          section=$(echo "$entry" | grep -oP '\(\K[^)]+' | head -1)
                          if [ -n "$section" ]; then
                            man "$section" "$name" 2>/dev/null || man "$name" 2>/dev/null || true
                          else
                            man "$name" 2>/dev/null || true
                          fi
                        done
                        ;;

                      "Search by keyword (apropos)")
                        while true; do
                          read -rp $'\napropos > keyword: ' kw 2>/dev/tty
                          [ -z "$kw" ] && break
                          entry=$(apropos "$kw" 2>/dev/null \
                            | sort \
                            | fzf_menu "apropos > $kw >" \
                                'echo {} | awk "{print \$1}" | xargs -I% sh -c "man -P cat % 2>/dev/null | head -80"' \
                            ) || break
                          is_back "$entry" && continue
                          [ -z "$entry" ] && continue
                          name=$(echo "$entry" | awk '{print $1}')
                          section=$(echo "$entry" | grep -oP '\(\K[^)]+' | head -1)
                          if [ -n "$section" ]; then
                            man "$section" "$name" 2>/dev/null || man "$name" 2>/dev/null || true
                          else
                            man "$name" 2>/dev/null || true
                          fi
                        done
                        ;;

                      "Direct name search")
                        while true; do
                          read -rp $'\nman > name: ' query 2>/dev/tty
                          [ -z "$query" ] && break
                          matches=$(man -k "^''${query}$" 2>/dev/null || man -k "$query" 2>/dev/null || true)
                          if [ -z "$matches" ]; then
                            echo "No man pages found for: $query"
                            read -rp "Press enter to continue..." 2>/dev/tty
                            continue
                          fi
                          entry=$(echo "$matches" \
                            | fzf_menu "man > $query >" \
                                'echo {} | awk "{print \$1}" | xargs -I% sh -c "man -P cat % 2>/dev/null | head -80"' \
                            ) || continue
                          is_back "$entry" && continue
                          [ -z "$entry" ] && continue
                          name=$(echo "$entry" | awk '{print $1}')
                          section=$(echo "$entry" | grep -oP '\(\K[^)]+' | head -1)
                          if [ -n "$section" ]; then
                            man "$section" "$name" 2>/dev/null || man "$name" 2>/dev/null || true
                          else
                            man "$name" 2>/dev/null || true
                          fi
                        done
                        ;;

                    esac
                  done
                }

                # ── TLDR ───────────────────────────────────────────────────────────────────────

                menu_tldr() {
                  while true; do
                    choice=$(printf '%s\n' \
                      "$BACK" \
                      "Browse all pages" \
                      "Direct name search" \
                      | fzf_menu "tldr >") || return

                    is_back "$choice" && return

                    case "$choice" in

                      "Browse all pages")
                        while true; do
                          entry=$(tldr --list 2>/dev/null \
                            | sort \
                            | fzf_menu "tldr > browse >" \
                                'tldr --color=always {}' \
                            ) || break
                          is_back "$entry" && break
                          [ -z "$entry" ] && continue
                          tldr "$entry" | less -FRX
                        done
                        ;;

                      "Direct name search")
                        while true; do
                          read -rp $'\ntldr > name: ' query 2>/dev/tty
                          [ -z "$query" ] && break
                          tldr "$query" 2>/dev/null | less -FRX || {
                            echo "No tldr page for: $query"
                            read -rp "Press enter to continue..." 2>/dev/tty
                          }
                        done
                        ;;

                    esac
                  done
                }

                # ── CHEAT ──────────────────────────────────────────────────────────────────────

                menu_cheat() {
                  while true; do
                    choice=$(printf '%s\n' \
                      "$BACK" \
                      "Browse community sheets" \
                      "Browse personal sheets" \
                      "Search across all sheets" \
                      | fzf_menu "cheat >") || return

                    is_back "$choice" && return

                    case "$choice" in

                      "Browse community sheets")
                        while true; do
                          entry=$(cheat -l -t community 2>/dev/null \
                            | tail -n +2 \
                            | awk '{print $1}' \
                            | sort \
                            | fzf_menu "cheat > community >" \
                                'cheat {}' \
                            ) || break
                          is_back "$entry" && break
                          [ -z "$entry" ] && continue
                          cheat "$entry" | less -FRX
                        done
                        ;;

                      "Browse personal sheets")
                        while true; do
                          entry=$(cheat -l -t personal 2>/dev/null \
                            | tail -n +2 \
                            | awk '{print $1}' \
                            | sort \
                            | fzf_menu "cheat > personal >" \
                                'cheat {}' \
                            ) || break
                          is_back "$entry" && break
                          [ -z "$entry" ] && continue
                          cheat "$entry" | less -FRX
                        done
                        ;;

                      "Search across all sheets")
                        while true; do
                          read -rp $'\ncheat > search keyword: ' kw 2>/dev/tty
                          [ -z "$kw" ] && break
                          entry=$(cheat -s "$kw" 2>/dev/null \
                            | grep '^##' \
                            | sed 's/^## //' \
                            | sort -u \
                            | fzf_menu "cheat > search > $kw >" \
                                'cheat {}' \
                            ) || continue
                          is_back "$entry" && continue
                          [ -z "$entry" ] && continue
                          cheat "$entry" | less -FRX
                        done
                        ;;

                    esac
                  done
                }

                # ── PINFO ──────────────────────────────────────────────────────────────────────

                menu_pinfo() {
                  while true; do
                    choice=$(printf '%s\n' \
                      "$BACK" \
                      "Browse topics" \
                      "Direct topic entry" \
                      | fzf_menu "pinfo >") || return

                    is_back "$choice" && return

                    case "$choice" in

                      "Browse topics")
                        while true; do
                          entry=$(info --output - dir 2>/dev/null \
                            | grep -oP '^\* \K[^:]+' \
                            | grep -v '^\s*$' \
                            | sort \
                            | fzf_menu "pinfo > browse >" \
                                'info --output - {} 2>/dev/null | head -60' \
                            ) || break
                          is_back "$entry" && break
                          [ -z "$entry" ] && continue
                          pinfo "$entry" 2>/dev/null || true
                        done
                        ;;

                      "Direct topic entry")
                        while true; do
                          read -rp $'\npinfo > topic: ' topic 2>/dev/tty
                          [ -z "$topic" ] && break
                          pinfo "$topic" 2>/dev/null || {
                            echo "No info page for: $topic"
                            read -rp "Press enter to continue..." 2>/dev/tty
                          }
                        done
                        ;;

                    esac
                  done
                }

                # ── NIXOS-OPTION ───────────────────────────────────────────────────────────────

                menu_nixos_option() {
                  while true; do
                    choice=$(printf '%s\n' \
                      "$BACK" \
                      "Query option directly" \
                      "Browse by prefix" \
                      | fzf_menu "nixos-option >") || return

                    is_back "$choice" && return

                    case "$choice" in

                      "Query option directly")
                        while true; do
                          read -rp $'\nnixos-option > path (e.g. services.openssh.enable): ' opt 2>/dev/tty
                          [ -z "$opt" ] && break
                          nixos-option "$opt" 2>/dev/null | less -FRX || {
                            echo "Option not found: $opt"
                            read -rp "Press enter to continue..." 2>/dev/tty
                          }
                        done
                        ;;

                      "Browse by prefix")
                        while true; do
                          read -rp $'\nnixos-option > prefix (e.g. services.nginx): ' prefix 2>/dev/tty
                          [ -z "$prefix" ] && break
                          result=$(nixos-option "$prefix" 2>/dev/null || true)
                          if [ -z "$result" ]; then
                            echo "No options found under: $prefix"
                            read -rp "Press enter to continue..." 2>/dev/tty
                            continue
                          fi
                          entry=$(echo "$result" \
                            | grep -oP '(?<=\. )[\w.-]+' \
                            | sort \
                            | fzf_menu "nixos-option > $prefix >" \
                                "nixos-option ''${prefix}.{} 2>/dev/null | head -40" \
                            ) || continue
                          is_back "$entry" && continue
                          [ -z "$entry" ] && continue
                          nixos-option "''${prefix}.''${entry}" 2>/dev/null | less -FRX || true
                        done
                        ;;

                    esac
                  done
                }

                # ── NIX REPL / NIX-DOC ─────────────────────────────────────────────────────────

                menu_nix_doc() {
                  while true; do
                    choice=$(printf '%s\n' \
                      "$BACK" \
                      "nix-doc: search Nix lib functions" \
                      "nix repl: open with nixpkgs" \
                      | fzf_menu "nix-doc >") || return

                    is_back "$choice" && return

                    case "$choice" in

                      "nix-doc: search Nix lib functions")
                        while true; do
                          read -rp $'\nnix-doc > query: ' query 2>/dev/tty
                          [ -z "$query" ] && break
                          nix-doc query "$query" 2>/dev/null | less -FRX || {
                            echo "No results for: $query"
                            read -rp "Press enter to continue..." 2>/dev/tty
                          }
                        done
                        ;;

                      "nix repl: open with nixpkgs")
                        nix repl '<nixpkgs>'
                        ;;

                    esac
                  done
                }

                # ── NixOS MANUAL / MAN CONFIGURATION ──────────────────────────────────────────

                menu_nixos_docs() {
                  while true; do
                    choice=$(printf '%s\n' \
                      "$BACK" \
                      "NixOS manual (browser)" \
                      "man configuration.nix" \
                      "man home-configuration.nix" \
                      "nixos-option submenu" \
                      "nix-doc / nix repl submenu" \
                      | fzf_menu "nixos >") || return

                    is_back "$choice" && return

                    case "$choice" in
                      "NixOS manual (browser)")       nixos-help ;;
                      "man configuration.nix")        man configuration.nix 2>/dev/null | less -FRX || true ;;
                      "man home-configuration.nix")   man home-configuration.nix 2>/dev/null | less -FRX || true ;;
                      "nixos-option submenu")         menu_nixos_option ;;
                      "nix-doc / nix repl submenu")   menu_nix_doc ;;
                    esac
                  done
                }

                # ── ZEAL / DEVDOCS ─────────────────────────────────────────────────────────────

                menu_devdocs() {
                  while true; do
                    choice=$(printf '%s\n' \
                      "$BACK" \
                      "Open Zeal (GUI offline API docs)" \
                      "dedoc: search (terminal DevDocs)" \
                      | fzf_menu "devdocs >") || return

                    is_back "$choice" && return

                    case "$choice" in

                      "Open Zeal (GUI offline API docs)")
                        zeal & disown
                        ;;

                      "dedoc: search (terminal DevDocs)")
                        while true; do
                          read -rp $'\ndedoc > query (e.g. "rust HashMap"): ' query 2>/dev/tty
                          [ -z "$query" ] && break
                          dedoc search $query 2>/dev/null | less -FRX || {
                            echo "No results. Try: dedoc search <language> <term>"
                            read -rp "Press enter to continue..." 2>/dev/tty
                          }
                        done
                        ;;

                    esac
                  done
                }

                # ── ASK AI ─────────────────────────────────────────────────────────────────────

                menu_ask() {
                  while true; do
                    read -rp $'\nask > question (or enter to exit): ' question 2>/dev/tty
                    [ -z "$question" ] && return

                    # Gather context about available docs
                    man_pages=$(man -k . 2>/dev/null | awk '{print $1}' | sort -u | tr '\n' ' ' | cut -c1-2000)
                    tldr_pages=$(tldr --list 2>/dev/null | sort | tr '\n' ' ' | cut -c1-1000)
                    zeal_docsets=$(find "$HOME/.local/share/Zeal/Zeal/docsets" /usr/share/zeal/docsets 2>/dev/null \
                      -maxdepth 1 -name '*.docset' \
                      | sed 's|.*/||; s|\.docset$||' \
                      | sort | tr '\n' ' ')

                    prompt="You are a documentation assistant. The user is on NixOS.

Available doc sources on this system:
- man: manual pages (man <page>)
- tldr: quick examples (tldr <page>)
- cheat: cheatsheets (cheat <page>)
- pinfo: GNU info pages (pinfo <topic>)
- nixos-option: NixOS options (nixos-option <path>)
- nix-doc: Nix lib functions (nix-doc query <term>)
- zeal: offline API docs — open with: zeal '<docset>:<query>'

Installed man pages (truncated): $man_pages

Installed tldr pages (truncated): $tldr_pages

Installed Zeal docsets: $zeal_docsets

User question: $question

Reply with ONLY a short bulleted list of the exact commands they should run to find relevant docs. Format each line as:
  • <command>  — <one sentence why>

No preamble, no explanation, no closing remarks. Only the list."

                    echo ""
                    echo "── AI suggestions ────────────────────────────────────────────────"
                    claude --print "$prompt" 2>/dev/null || {
                      echo "Error: claude CLI not found or not logged in."
                      echo "Install with: npm install -g @anthropic-ai/claude-code"
                    }
                    echo "──────────────────────────────────────────────────────────────────"
                    echo ""
                    read -rp "Press enter to ask another, or leave blank to go back: " again 2>/dev/tty
                    [ -z "$again" ] && return
                  done
                }

                # ── TOP-LEVEL MENU ─────────────────────────────────────────────────────────────

                while true; do
                  top=$(printf '%s\n' \
                    "man -- manual pages" \
                    "tldr -- tealdeer quick examples" \
                    "cheat -- community & personal cheatsheets" \
                    "pinfo -- GNU info browser" \
                    "nixos -- NixOS/HM docs, options, nix-doc" \
                    "devdocs -- Zeal & dedoc offline API docs" \
                    "ask -- AI doc suggestions" \
                    | fzf_menu "docs >") || exit 0

                  case "$top" in
                    "man"*)     menu_man ;;
                    "tldr"*)    menu_tldr ;;
                    "cheat"*)   menu_cheat ;;
                    "pinfo"*)   menu_pinfo ;;
                    "nixos"*)   menu_nixos_docs ;;
                    "devdocs"*) menu_devdocs ;;
                    "ask"*)     menu_ask ;;
                  esac
                done

            '';
    };
}
