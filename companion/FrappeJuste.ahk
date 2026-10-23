#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent
; ============================================================
; Frappe Juste — Compagnon portable (généré le 23.10.2026, clavier Suisse (FR))
; Compilé en FrappeJuste.exe par GitHub Actions (voir .github/workflows).
; Sans compilation : placer à côté de AutoHotkey64.exe sous le nom AutoHotkey64.ahk.
;   Ctrl+Alt+P        : palette de caractères flottante
;   lettre maintenue + Espace (ou flèches) : accents, relâcher pour insérer
;   abréviation + Espace / Tab / Entrée     : développement
; ============================================================
#Hotstring EndChars `n `t
A_IconTip := "Frappe Juste Compagnon"
global QA_ON := true
global Pal := ""
global PAL_CHARS := ["@", "#", "€", "|", "\", "[", "]", "{", "}", "~", "¦", "¬", "¢", "¤", "µ", "²", "ù", "ê", "â", "î", "ô", "û", "ë", "ï", "ÿ", "ñ", "É", "È", "À", "Ê", "Â", "Î", "Ô", "Û", "Ë", "Ï", "Ù", "Ç", "Ñ", "^", "``", "´", "¨", "«", "»", "’", "“", "”", "–", "—", "…", "œ", "Œ", "æ", "ß", "³", "½", "¼", "×", "÷", "±", "≠", "≤", "≥", "≈", "→", "←", "∞", "©", "®", "™", "•", "†", "‰", "¶", "¿", "¡"]
global ACC := Map("0", "°", "1", "¹½¼", "2", "²", "3", "³¾", "a", "àâäæáãå", "e", "éèêë€", "i", "îïíì", "o", "ôöœóòõø", "u", "ùûüú", "c", "ç©¢", "n", "ñ", "y", "ÿý", "s", "ß§", "t", "™", "r", "®", "x", "×", "é", "èêë", "è", "éêë", "à", "âäæ", "ö", "ôœ", "ü", "ûù", "ä", "âæ", "<", "«≤‹", ">", "»≥›", "-", "–—±", ".", "…•·", "'", "’‘", "`"", "“”«»", "/", "÷", "=", "≠≈", "!", "¡", "?", "¿", "$", "€£¥", "*", "•†")
global QA := {key: "", tick: 0, reps: 0, open: false, idx: 0, up: false, list: ""}

; ---------- menu de l'icône ----------
A_TrayMenu.Delete()
A_TrayMenu.Add("Palette de caractères (Ctrl+Alt+P)", MenuPalette)
A_TrayMenu.Add("Quick Accent", MenuQA)
A_TrayMenu.Check("Quick Accent")
A_TrayMenu.Add("Pause", MenuPause)
A_TrayMenu.Add()
A_TrayMenu.Add("Recharger", (*) => Reload())
A_TrayMenu.Add("Quitter", (*) => ExitApp())
A_TrayMenu.Default := "Palette de caractères (Ctrl+Alt+P)"

MenuPalette(*) {
  TogglePalette()
}
MenuQA(name, *) {
  global QA_ON
  QA_ON := !QA_ON
  A_TrayMenu.ToggleCheck(name)
}
MenuPause(name, *) {
  Suspend(-1)
  A_TrayMenu.ToggleCheck(name)
}

; ---------- palette flottante ----------
^!p::TogglePalette()

TogglePalette() {
  global Pal
  if IsObject(Pal) {
    Pal.Destroy()
    Pal := ""
    return
  }
  Pal := Gui("+AlwaysOnTop +ToolWindow +E0x08000000", "Frappe Juste")
  Pal.SetFont("s11", "Segoe UI")
  for i, c in PAL_CHARS {
    x := 6 + Mod(i - 1, 10) * 34
    y := 6 + ((i - 1) // 10) * 34
    btn := Pal.AddButton("x" x " y" y " w32 h32", c = "&" ? "&&" : c)
    btn.OnEvent("Click", PalSend.Bind(c))
  }
  Pal.OnEvent("Close", PalClose)
  rows := Ceil(PAL_CHARS.Length / 10)
  w := 10 * 34 + 10
  h := rows * 34 + 10
  Pal.Show("NoActivate w" w " h" h " x" (A_ScreenWidth - w - 30) " y" (A_ScreenHeight - h - 90))
}
PalSend(c, *) {
  SendText(c)
}
PalClose(*) {
  global Pal
  Pal.Destroy()
  Pal := ""
}

; ---------- Quick Accent ----------
ih := InputHook("V L0 I1")
ih.KeyOpt("{All}", "N")
ih.OnKeyDown := QA_Down
ih.OnKeyUp := QA_Up
ih.Start()

QA_Down(ih, vk, sc) {
  global QA, ACC, QA_ON
  if !QA_ON
    return
  name := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
  if (StrLen(name) != 1)
    return
  if (QA.key != "" && name = QA.key) {
    QA.reps += 1
    return
  }
  if QA.open
    return
  k := StrLower(name)
  if ACC.Has(k) {
    QA.key := name
    QA.tick := A_TickCount
    QA.reps := 0
    QA.idx := 0
    QA.up := GetKeyState("Shift")
    QA.list := ACC[k]
  } else
    QA.key := ""
}

QA_Up(ih, vk, sc) {
  global QA
  name := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
  if (QA.key = "" || name != QA.key)
    return
  if QA.open {
    lst := QA_List()
    ch := lst[QA.idx]
    ToolTip()
    Send("{BS " (1 + QA.reps) "}")
    SendText(ch)
  }
  QA.key := ""
  QA.open := false
  QA.reps := 0
}

QA_List() {
  global QA
  lst := StrSplit(QA.list)
  if QA.up {
    for i, c in lst
      lst[i] := StrUpper(c)
  }
  return lst
}

AccentReady() {
  global QA, QA_ON
  if (!QA_ON || QA.key = "")
    return false
  return QA.open || (A_TickCount - QA.tick >= 300)
}

QA_Step(d) {
  global QA
  lst := QA_List()
  if !QA.open {
    QA.open := true
    QA.idx := d > 0 ? 1 : lst.Length
  } else {
    QA.idx += d
    if (QA.idx > lst.Length)
      QA.idx := 1
    if (QA.idx < 1)
      QA.idx := lst.Length
  }
  s := ""
  for i, c in lst
    s .= (i = QA.idx) ? " [" c "] " : "  " c "  "
  if CaretGetPos(&cx, &cy)
    ToolTip(s, cx, cy + 24)
  else
    ToolTip(s)
}

QA_Cancel() {
  global QA
  ToolTip()
  QA.open := false
  QA.key := ""
}

#HotIf AccentReady()
Space::QA_Step(1)
+Space::QA_Step(-1)
Right::QA_Step(1)
Left::QA_Step(-1)
Esc::QA_Cancel()
#HotIf

; ---------- abréviations ----------
:O:<<::
{
  SendText "« "
}

:O:>>::
{
  SendText " »"
}

:CO:;oe::
{
  SendText "œ"
}

:CO:;OE::
{
  SendText "Œ"
}

:O:--::
{
  SendText "—"
}

:O:;no::
{
  SendText "n°"
}

:O:;deg::
{
  SendText "°"
}

:O:;tm::
{
  SendText "™"
}

:O:;r::
{
  SendText "®"
}

:O:;c::
{
  SendText "©"
}

:O:;x::
{
  SendText "×"
}

:O:;bj::
{
  v1 := InputBox("Madame / Monsieur / à tous", "Frappe Juste", , "Madame").Value
  SendText "Bonjour " . v1 . ",`n`n"
}

:O:;cdt::
{
  SendText "Avec mes meilleures salutations,`n`nJustin Fabrice MANGA ZAMBO"
}

:O:;merci::
{
  SendText "Je vous remercie par avance de votre retour et reste à votre disposition pour tout complément d'information."
}

:O:;pj::
{
  v1 := InputBox("Document", "Frappe Juste", , "").Value
  SendText "Veuillez trouver ci-joint " . v1 . "."
}

:O:;rdv::
{
  v1 := InputBox("Jour", "Frappe Juste", , "").Value
  v2 := InputBox("Heure", "Frappe Juste", , "").Value
  SendText "Je vous propose de nous rencontrer le " . v1 . " à " . v2 . "."
}

:O:;auj::
{
  SendText FormatTime(, "d MMMM yyyy")
}

:O:;oapi::
{
  SendText "Organisation Africaine de la Propriété Intellectuelle (OAPI)"
}

:O:;ompi::
{
  SendText "Organisation Mondiale de la Propriété Intellectuelle (OMPI)"
}

:O:;bangui::
{
  SendText "Accord de Bangui (Acte de Bamako, 2015)"
}

:O:;madrid::
{
  SendText "Protocole relatif à l'Arrangement de Madrid concernant l'enregistrement international des marques"
}

:O:;ei::
{
  SendText "enregistrement international"
}

:O:;rp::
{
  SendText "refus provisoire de protection"
}

:O:;ref::
{
  v1 := InputBox("Référence", "Frappe Juste", , "").Value
  SendText "N/Réf. : " . v1
}
