# Copy my SSH public key to the clipboard.
# Prefers ed25519, then rsa, then any *.pub. Uses the cross-platform
# clipboard abstraction (see system/clipboard.zsh).
pubkey() {
  local key
  for key in ~/.ssh/id_ed25519.pub ~/.ssh/id_rsa.pub ~/.ssh/*.pub(N); do
    [[ -f "$key" ]] || continue
    dot_clipboard_copy < "$key"
    echo "=> Public key copied to clipboard: $key"
    return 0
  done
  echo "pubkey: no SSH public key found in ~/.ssh" >&2
  return 1
}
