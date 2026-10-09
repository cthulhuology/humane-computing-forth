# Require a blank line, a descriptive backslash comment, optional contiguous
# backslash documentation, then every colon, CODE or constant definition.
# Constants also end with a blank line so source inspection stays focused.
FNR == 1 {
    comment_block = 0
    previous_blank = 1
    constant_line = 0
}
{
    if (constant_line && $0 !~ /^[[:space:]]*$/) {
        printf "%s:%d: constant needs a trailing blank line\n", FILENAME, FNR - 1
        failed = 1
    }
    constant_line = 0
}
/^\\([[:space:]]|$)/ {
    if (!comment_block) {
        preceded_by_blank = previous_blank
        has_summary = ($0 ~ /^\\[[:space:]]+[^[:space:]]/)
    }
    comment_block = 1
    previous_blank = 0
    next
}
/(^|[[:space:]])locals\|([[:space:]]|$)/ {
    printf "%s:%d: local declarations are prohibited; use stacks and named context variables\n", FILENAME, FNR
    failed = 1
}
/^(:|code)[[:space:]]/ || ($2 == "constant" && $1 != "\\") {
    if (!comment_block || !preceded_by_blank || !has_summary) {
        printf "%s:%d: word needs a blank line and a descriptive backslash comment\n", FILENAME, FNR
        failed = 1
    }
    if ($2 == "constant" && $1 != ":") constant_line = 1
}
{
    comment_block = 0
    previous_blank = ($0 ~ /^[[:space:]]*$/)
}
END { exit failed }
