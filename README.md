# Dotfiles Migration Checklist (Fedora)

This README is a **personal migration guide** — a reminder of what to do when setting up a new computer and restoring my development environment.

---

## 1. Restore Existing SSH Key Pairs

### Copy SSH keys from backup

Place your existing SSH keys into the `.ssh` directory:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# copy your keys here
cp id_ed25519  id_ed25519.pub ~/.ssh/
```

> Replace `id_rsa` with your actual key names if different.

### Fix permissions

```bash
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Add key to SSH agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Test SSH

```bash
ssh -T git@github.com
```

---

## 2. Restore Existing GPG Key Pairs

### Import private and public keys

```bash
gpg --import private.key
gpg --import public.key
```

Or if exporting from another system:

```bash
gpg --export-secret-keys --armor YOUR_KEY_ID > private.key
gpg --export --armor YOUR_KEY_ID > public.key
```

### Verify keys

```bash
gpg --list-secret-keys --keyid-format=long
```

Copy the **KEY ID** (the part after `rsa4096/`).

### Set trust level

```bash
gpg --edit-key YOUR_KEY_ID
trust
5
y
quit
```

---

## 3. Configure Git to Use GPG Signing

### Set user identity

```bash
git config --global user.name "Ashen Chathuranga"
git config --global user.email "ktauchathuranga@gmail.com"
```

### Tell Git which GPG key to use

```bash
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
git config --global gpg.program gpg
```

### Fix GPG TTY issue (important)

Add this to `~/.bashrc` or `~/.zshrc`:

```bash
export GPG_TTY=$(tty)
```

Reload shell:

```bash
source ~/.bashrc
```

### Test commit signing

```bash
git commit -S -m "test signed commit"
```

---

## 4. Git Aliases & Quality-of-Life Config

### Git shortcuts

```bash
git config --global alias.ck checkout
git config --global alias.br branch
git config --global alias.st status
git config --global alias.sw switch
git config --global alias.lg "log --oneline --decorate --all --graph"
git config --global alias.ps push
git config --global alias.pl pull
git config --global alias.ad "add ."
git config --global alias.cm "commit -m"
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"
git config --global alias.cl clone
```

---

