# Lexical filtering is only for source inventories, never for proof checking.
if (-not ('ThomsonN9LeanSourceV1' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
public static class ThomsonN9LeanSourceV1 {
    public static string CodeOnly(string source) {
        char[] result = source.ToCharArray();
        int i = 0;
        while (i < source.Length) {
            int start = i;
            if (i + 1 < source.Length && source[i] == '-' && source[i+1] == '-') {
                i += 2;
                while (i < source.Length && source[i] != '\n' && source[i] != '\r') i++;
            } else if (i + 1 < source.Length && source[i] == '/' && source[i+1] == '-') {
                int depth = 1;
                i += 2;
                while (i < source.Length && depth != 0) {
                    if (i + 1 < source.Length && source[i] == '/' && source[i+1] == '-') {
                        depth++; i += 2;
                    } else if (i + 1 < source.Length && source[i] == '-' && source[i+1] == '/') {
                        depth--; i += 2;
                    } else i++;
                }
                if (depth != 0) throw new ArgumentException("Unclosed Lean block comment.");
            } else {
                int quote = i;
                int hashes = -1;
                if (source[i] == 'r') {
                    quote++;
                    while (quote < source.Length && source[quote] == '#') quote++;
                    if (quote < source.Length && source[quote] == '"') hashes = quote - i - 1;
                }
                if (source[i] == '"' || hashes >= 0) {
                    if (hashes < 0) quote = i;
                    i = quote + 1;
                    bool closed = false;
                    while (i < source.Length) {
                        if (hashes < 0 && source[i] == '\\') { i += 2; continue; }
                        if (source[i] == '"') {
                            int end = i + 1;
                            int n = Math.Max(hashes, 0);
                            while (n > 0 && end < source.Length && source[end] == '#') { n--; end++; }
                            if (n == 0) { i = end; closed = true; break; }
                        }
                        i++;
                    }
                    if (!closed) throw new ArgumentException("Unclosed Lean string literal.");
                } else if (source[i] == '\'' && i + 2 < source.Length && source[i+2] == '\'') {
                    i += 3;
                } else if (source[i] == '\'' && i + 3 < source.Length && source[i+1] == '\\' && source[i+3] == '\'') {
                    i += 4;
                } else { i++; continue; }
            }
            for (int j = start; j < i; j++) {
                if (result[j] != '\r' && result[j] != '\n') result[j] = ' ';
            }
        }
        return new string(result);
    }
}
'@
}
function Get-LeanCodeLines([string]$Path) {
    [ThomsonN9LeanSourceV1]::CodeOnly([IO.File]::ReadAllText($Path)) -split '\r?\n'
}
