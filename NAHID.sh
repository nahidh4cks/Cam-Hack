#!/usr/bin/env bash
# ============================================================
#   NAHID CAM HACK ::  QUANTUM AUTO-INSTALLER & LAUNCHER v2
#   Telegram : https://t.me/nahidh4cks
#   YouTube  : https://youtube.com/@nahidh4cksisback
# ============================================================
#   bash setup.sh              → প্রথমবার সব ইনস্টল + রান, পরেরবার সরাসরি রান
#   bash setup.sh --reinstall  → জোর করে সব আবার ইনস্টল
#   bash setup.sh --check      → শুধু সব মডিউল ঠিক আছে কিনা যাচাই
#   bash setup.sh --no-run     → ইনস্টল করে বন্ধ (বট রান করবে না)
#   এরপর যেকোনো জায়গা থেকে শুধু লিখুন:  nahid
# ============================================================

cd "$(dirname "${BASH_SOURCE[0]:-$0}")" || exit 1
ROOT="$(pwd)"
LOG="$ROOT/setup_log.txt"
MARK="$ROOT/.nahid_installed"
TG_LINK="https://t.me/nahidh4cks"
YT_LINK="https://youtube.com/@nahidh4cksisback"
START_TS=$(date +%s)

# ---------- colors ----------
R=$'\033[0m'; B=$'\033[1m'; D=$'\033[2m'
RED=$'\033[91m'; GRN=$'\033[92m'; YLW=$'\033[93m'; BLU=$'\033[94m'
CYN=$'\033[96m'; PNK=$'\033[38;5;206m'
RGB=( $'\033[38;5;196m' $'\033[38;5;208m' $'\033[38;5;226m' $'\033[38;5;118m'
      $'\033[38;5;51m'  $'\033[38;5;45m'  $'\033[38;5;93m'  $'\033[38;5;201m'
      $'\033[38;5;198m' $'\033[38;5;214m' $'\033[38;5;220m' $'\033[38;5;154m'
      $'\033[38;5;57m'  $'\033[38;5;129m' $'\033[38;5;212m' )
RL=${#RGB[@]}

IS_TERMUX=0
{ [ -n "$TERMUX_VERSION" ] || [ -d /data/data/com.termux ]; } && IS_TERMUX=1

# ---------- args ----------
FORCE=0; CHECK_ONLY=0; NO_RUN=0
for a in "$@"; do
    case "$a" in
        --reinstall) FORCE=1 ;;
        --check)     CHECK_ONLY=1 ;;
        --no-run)    NO_RUN=1 ;;
    esac
done
[ -n "$NAHID_NO_RUN" ] && NO_RUN=1
: > "$LOG"

# ---------- tiny helpers ----------
ok()   { printf '  %s%s[✔]%s %s\n' "$GRN" "$B" "$R" "$*"; }
warn() { printf '  %s%s[!]%s %s\n' "$YLW" "$B" "$R" "$*"; }
err()  { printf '  %s%s[✗]%s %s\n' "$RED" "$B" "$R" "$*"; }
step() { printf '\n  %s%s◆ %s%s\n' "$CYN" "$B" "$*" "$R"; }
elapsed() { local s=$(( $(date +%s) - START_TS )); printf '%dm %02ds' $(( s / 60 )) $(( s % 60 )); }

LOGO=(
"███╗   ██╗ █████╗ ██╗  ██╗██╗██████╗ "
"████╗  ██║██╔══██╗██║  ██║██║██╔══██╗"
"██╔██╗ ██║███████║███████║██║██║  ██║"
"██║╚██╗██║██╔══██║██╔══██║██║██║  ██║"
"██║ ╚████║██║  ██║██║  ██║██║██████╔╝"
"╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═════╝ "
)

draw_logo() {  # $1 = offset
    local i=0 line
    for line in "${LOGO[@]}"; do
        printf '  %s%s%s%s\033[K\n' "${RGB[$(( (i * 2 + $1) % RL ))]}" "$B" "$line" "$R"
        i=$(( i + 1 ))
    done
}

typewriter() {  # $1=text $2=delay
    local s="$1" d="${2:-0.012}" i
    for (( i=0; i<${#s}; i++ )); do printf '%s' "${s:$i:1}"; sleep "$d"; done
    printf '\n'
}

banner() {
    clear 2>/dev/null; echo ""
    local f off=$(( RANDOM % RL ))
    if [ -t 1 ]; then
        for f in 1 2 3 4 5 6 7 8; do
            draw_logo $(( off + f ))
            [ "$f" -lt 8 ] && printf '\033[6A'
            sleep 0.07
        done
    else
        draw_logo "$off"
    fi
    printf '  %s%s     ⚡  C A M H 4 C K  ⚡%s\n' "$YLW" "$B" "$R"
    printf '  %s%s  ──────────────────────────────────────────%s\n' "$PNK" "$B" "$R"
    printf '  %s%s  Telegram : %s%s\n' "$CYN" "$B" "$TG_LINK" "$R"
    printf '  %s%s  YouTube  : %s%s\n' "$CYN" "$B" "$YT_LINK" "$R"
    printf '  %s%s  ──────────────────────────────────────────%s\n' "$PNK" "$B" "$R"
}

sysinfo() {
    local arch pyv env="Linux"
    arch="$(uname -m 2>/dev/null)"
    pyv="$(python3 --version 2>&1 | awk '{print $2}')"; [ -z "$pyv" ] && pyv="—"
    [ "$IS_TERMUX" -eq 1 ] && env="Termux (Android)"
    printf '  %s┌─ SYSTEM ───────────────────────────────┐%s\n' "$BLU" "$R"
    printf '  %s│%s  পরিবেশ  : %-27s%s│%s\n' "$BLU" "$R" "$env" "$BLU" "$R"
    printf '  %s│%s  আর্কিটেকচার: %-24s%s│%s\n' "$BLU" "$R" "$arch" "$BLU" "$R"
    printf '  %s│%s  পাইথন   : %-27s%s│%s\n' "$BLU" "$R" "$pyv" "$BLU" "$R"
    printf '  %s└────────────────────────────────────────┘%s\n\n' "$BLU" "$R"
}

bar() {  # $1=done $2=total
    local w=30 f=$(( $1 * 30 / $2 )) i out=""
    for (( i=0; i<w; i++ )); do
        if (( i < f )); then out+="${RGB[$(( (i + $1) % RL ))]}█"; else out+="${D}░"; fi
    done
    printf '%s%s' "$out" "$R"
}

# spinner: run "$@" in background, animate until done, return its exit code
SPIN=( '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏' )
run_spin() {  # $1=label, rest=command
    local label="$1"; shift
    "$@" >>"$LOG" 2>&1 &
    local pid=$! i=0
    if [ -t 1 ]; then
        while kill -0 "$pid" 2>/dev/null; do
            printf '\r  %s%s%s %s' "${RGB[$(( i % RL ))]}" "${SPIN[$(( i % 10 ))]}" "$R" "$label"
            i=$(( i + 1 )); sleep 0.1
        done
        printf '\r\033[2K'
    fi
    wait "$pid"
}

# ---------- bot files check ----------
for f in main.py message_ids.py thunderFF_pb2.py nahid/index.html; do
    if [ ! -f "$f" ]; then
        banner
        err "ফাইল পাওয়া যায়নি: $f  (জিপ পুরোটা এক্সট্র্যাক্ট করেছেন তো?)"
        exit 1
    fi
done

# ---------- required python modules (requirements.txt না থাকলে এটাই ব্যবহার হবে) ----------
FALLBACK_REQS=( httpx aiohttp requests pycryptodome "protobuf>=6.30.0" protobuf-decoder google-play-scraper )
if [ -f requirements.txt ]; then
    mapfile -t REQS < <(grep -vE '^\s*(#|$)' requirements.txt | tr -d '\r')
else
    REQS=( "${FALLBACK_REQS[@]}" )
fi
[ "${#REQS[@]}" -eq 0 ] && REQS=( "${FALLBACK_REQS[@]}" )

# ---------- import verification ----------
verify_imports() {
    python3 - <<'PYEOF'
import importlib, sys
mods = ["httpx", "aiohttp", "requests", "Crypto.Cipher.AES", "Crypto.Util.Padding",
        "google.protobuf", "protobuf_decoder.protobuf_decoder", "google_play_scraper",
        "thunderFF_pb2", "StartMatch_pb2", "reqClan_pb2", "message_ids"]
bad = 0
for m in mods:
    try:
        importlib.import_module(m)
        print(f"  \033[92m✅ {m}\033[0m")
    except Exception as e:
        print(f"  \033[91m❌ {m}  →  {type(e).__name__}: {e}\033[0m")
        bad += 1
sys.exit(1 if bad else 0)
PYEOF
}

# ---------- shortcut command: nahid ----------
make_shortcut() {
    local dir
    if [ "$IS_TERMUX" -eq 1 ] && [ -n "$PREFIX" ]; then dir="$PREFIX/bin"; else dir="$HOME/.local/bin"; fi
    mkdir -p "$dir" 2>/dev/null || return 0
    printf '#!/usr/bin/env bash\nexec bash "%s/setup.sh" "$@"\n' "$ROOT" > "$dir/nahid" 2>/dev/null \
        && chmod +x "$dir/nahid" 2>/dev/null \
        && ok "শর্টকাট তৈরি: এখন যেকোনো জায়গা থেকে শুধু ${B}nahid${R} লিখলেই বট চালু হবে"
}

# ============================================================
#  INSTALL PHASE
# ============================================================
install_all() {
    # --- 1. Termux storage + packages ---
    if [ "$IS_TERMUX" -eq 1 ]; then
        step "স্টোরেজ পারমিশন"
        if [ -d "$HOME/storage/shared" ]; then
            ok "স্টোরেজ পারমিশন আগে থেকেই আছে"
        else
            warn "পারমিশন চাওয়া হচ্ছে — 'Allow' চাপুন"
            termux-setup-storage; sleep 4
        fi

        step "প্যাকেজ লিস্ট আপডেট"
        export DEBIAN_FRONTEND=noninteractive
        run_spin "pkg update চলছে (একটু সময় লাগবে)..." \
            pkg update -y -o Dpkg::Options::="--force-confold" || true
        run_spin "pkg upgrade চলছে..." \
            pkg upgrade -y -o Dpkg::Options::="--force-confold" || true
        ok "প্যাকেজ আপডেট সম্পূর্ণ"

        step "সিস্টেম প্যাকেজ ইনস্টল"
        SYS=( python clang make pkg-config libffi openssl binutils )
        local n=0 t=${#SYS[@]} p
        for p in "${SYS[@]}"; do
            n=$(( n + 1 ))
            if run_spin "$p  [$n/$t]" pkg install -y "$p"; then
                printf '  %s✅ %-14s [%d/%d]%s\n' "$GRN" "$p" "$n" "$t" "$R"
            else
                # একবার আবার চেষ্টা (মিরর সমস্যা হলে কাজে লাগে)
                if run_spin "$p আবার চেষ্টা..." pkg install -y "$p"; then
                    printf '  %s✅ %-14s [%d/%d] (২য় চেষ্টায়)%s\n' "$GRN" "$p" "$n" "$t" "$R"
                else
                    printf '  %s❌ %-14s ব্যর্থ%s\n' "$RED" "$p" "$R"
                fi
            fi
        done
    fi

    # --- 2. python check ---
    step "পাইথন যাচাই"
    if command -v python3 >/dev/null 2>&1; then
        ok "পাইথন: $(python3 --version 2>&1)"
    else
        err "পাইথন নেই! Termux হলে চালান:  pkg install python"
        exit 1
    fi

    # Termux-এ pip নিজে আপগ্রেড করা যায় না; অন্য সিস্টেমে চুপচাপ আপগ্রেড
    if [ "$IS_TERMUX" -eq 0 ]; then
        python3 -m pip install -q -U pip setuptools wheel >>"$LOG" 2>&1 \
            || python3 -m pip install -q -U --break-system-packages pip setuptools wheel >>"$LOG" 2>&1 || true
    fi

    # --- 3. pip modules (৩ ধাপে চেষ্টা, ২ রাউন্ড) ---
    step "পাইথন মডিউল ইনস্টল"
    export MATHLIB=m PIP_DISABLE_PIP_VERSION_CHECK=1
    export AIOHTTP_NO_EXTENSIONS=1 MULTIDICT_NO_EXTENSIONS=1
    export YARL_NO_EXTENSIONS=1 FROZENLIST_NO_EXTENSIONS=1

    local TOTAL=${#REQS[@]} DONE=0 spec name round good
    FAILED=()
    for spec in "${REQS[@]}"; do
        DONE=$(( DONE + 1 ))
        name="${spec%%[<>=!~ ]*}"
        good=0
        for round in 1 2; do
            if run_spin "$name  [$DONE/$TOTAL] (চেষ্টা $round)" \
                   python3 -m pip install --prefer-binary -q "$spec" \
               || run_spin "$name  [$DONE/$TOTAL] (চেষ্টা $round)" \
                   python3 -m pip install --prefer-binary -q --break-system-packages "$spec" \
               || run_spin "$name  [$DONE/$TOTAL] (চেষ্টা $round)" \
                   python3 -m pip install -q --no-cache-dir --break-system-packages "$spec"; then
                good=1; break
            fi
        done
        if [ "$good" -eq 1 ]; then
            printf '  %s✅ %-22s সফল%s\n' "$GRN" "$name" "$R"
        else
            printf '  %s❌ %-22s ব্যর্থ%s\n' "$RED" "$name" "$R"
            FAILED+=( "$spec" )
        fi
        printf '     '; bar "$DONE" "$TOTAL"; printf '  %d%%\n' $(( DONE * 100 / TOTAL ))
    done

    # --- 4. verify (+ self-heal) ---
    step "সব মডিউল লোড হচ্ছে কিনা যাচাই"
    if ! verify_imports; then
        warn "কিছু মডিউল লোড হয়নি — স্বয়ংক্রিয়ভাবে মেরামতের চেষ্টা..."
        python3 -m pip install -q --force-reinstall --no-cache-dir --break-system-packages \
            pycryptodome "protobuf>=6.30.0" >>"$LOG" 2>&1 || true
        echo ""
        verify_imports
    fi
    local VERIFY=$?

    echo ""
    printf '  %s%s══════════════════════════════════════════════%s\n' "$BLU" "$B" "$R"
    if [ "$VERIFY" -eq 0 ]; then
        ok "সব প্যাকেজ ও মডিউল সফলভাবে ইনস্টল হয়েছে! 😊   (সময়: $(elapsed))"
        date > "$MARK"
        find "$ROOT" -maxdepth 2 -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null
        make_shortcut
    else
        warn "কিছু মডিউল এখনও লোড হয়নি। ইন্টারনেট চেক করে আবার চালান:  bash setup.sh --reinstall"
        warn "বিস্তারিত এরর: $LOG"
        [ "${#FAILED[@]}" -gt 0 ] && warn "ব্যর্থ: ${FAILED[*]}"
        exit 1
    fi
    printf '  %s%s══════════════════════════════════════════════%s\n\n' "$BLU" "$B" "$R"

    # --- 5. Telegram (শুধু প্রথমবার) ---
    step "Telegram চ্যানেল ওপেন"
    if command -v termux-open-url >/dev/null 2>&1; then
        termux-open-url "$TG_LINK" >/dev/null 2>&1 || true
    elif command -v termux-open >/dev/null 2>&1; then
        termux-open "$TG_LINK" >/dev/null 2>&1 || true
    elif command -v am >/dev/null 2>&1; then
        am start -a android.intent.action.VIEW -d "$TG_LINK" >/dev/null 2>&1 || true
    fi
    ok "$TG_LINK"
    sleep 2
}

# ============================================================
#  MAIN FLOW
# ============================================================
banner
sysinfo

if [ "$CHECK_ONLY" -eq 1 ]; then
    step "শুধু যাচাই মোড"
    verify_imports && ok "সব ঠিক আছে ✔" || { err "সমস্যা আছে — চালান: bash NAHID.sh--reinstall"; exit 1; }
    exit 0
fi

if [ "$FORCE" -eq 1 ] || [ ! -f "$MARK" ]; then
    install_all
else
    # আগে ইনস্টল হয়েছে — তবু চুপচাপ দ্রুত যাচাই; কিছু নষ্ট হলে নিজেই আবার ইনস্টল
    if verify_imports >/dev/null 2>&1; then
        ok "আগেই ইনস্টল করা আছে — সরাসরি রান হচ্ছে  ${D}(জোর করে ইনস্টল: bash NAHID.sh --reinstall)${R}"
    else
        warn "কিছু মডিউল নষ্ট/মিসিং — স্বয়ংক্রিয়ভাবে আবার ইনস্টল হচ্ছে..."
        install_all
    fi
fi

if [ "$NO_RUN" -eq 1 ]; then
    ok " রান করা হলো না (--no-run)"
    exit 0
fi

# ============================================================
#  RUN  (free-port + wake-lock + auto-restart watchdog)
# ============================================================
command -v termux-wake-lock >/dev/null 2>&1 && termux-wake-lock 2>/dev/null

# পোর্ট দখল থাকলে পরের ফাঁকা পোর্ট নেয়
PORT_WANT="${PORT:-${SERVER_PORT:-25567}}"
PORT_USE="$(python3 - "$PORT_WANT" <<'PYEOF'
import socket, sys
p = int(sys.argv[1])
for q in range(p, p + 30):
    s = socket.socket()
    try:
        s.bind(("127.0.0.1", q)); s.close(); print(q); break
    except OSError:
        s.close()
else:
    print(p)
PYEOF
)"
[ -z "$PORT_USE" ] && PORT_USE="$PORT_WANT"
export PORT="$PORT_USE"
[ "$PORT_USE" != "$PORT_WANT" ] && warn "পোর্ট $PORT_WANT ব্যস্ত ছিল — $PORT_USE ব্যবহার হচ্ছে"

echo ""
printf '  %s%s🚀 ' "$GRN" "$B"; typewriter " চালু হচ্ছে..." 0.03; printf '%s' "$R"
printf '  %s%s🌐 ড্যাশবোর্ড: http://127.0.0.1:%s  (ব্রাউজারে খুলুন)%s\n' "$CYN" "$B" "$PORT_USE" "$R"
printf '  %s%s🛡  ক্র্যাশ করলে নিজে থেকে রিস্টার্ট হবে%s\n' "$YLW" "$B" "$R"
printf '  %s%s⛔ বন্ধ করতে: CTRL + C%s\n\n' "$D" "$B" "$R"
sleep 2

STOP=0
trap 'STOP=1' INT TERM
CRASHES=0; DELAY=3
while [ "$STOP" -eq 0 ]; do
    T0=$(date +%s)
    python3 main.py
    RC=$?
    [ "$STOP" -eq 1 ] && break
    [ "$RC" -eq 0 ] && break
    [ "$RC" -eq 130 ] && break

    # দীর্ঘ সময় চলার পর ক্র্যাশ হলে কাউন্টার রিসেট
    [ $(( $(date +%s) - T0 )) -gt 120 ] && { CRASHES=0; DELAY=3; }
    CRASHES=$(( CRASHES + 1 ))
    if [ "$CRASHES" -gt 8 ]; then
        err "বার বার ক্র্যাশ করছে (exit $RC) — থামানো হলো। সমস্যা থাকলে চালান: bash NAHID.sh --reinstall"
        break
    fi
    warn "বট বন্ধ হয়ে গেছে (exit $RC) — ${DELAY}s পর রিস্টার্ট  [$CRASHES/8]"
    sleep "$DELAY"; DELAY=$(( DELAY * 2 )); [ "$DELAY" -gt 30 ] && DELAY=30
done

command -v termux-wake-unlock >/dev/null 2>&1 && termux-wake-unlock 2>/dev/null
printf '\n  %s%s👋 বন্ধ হয়েছে। আবার চালাতে লিখুন: nahid%s\n\n' "$PNK" "$B" "$R"
