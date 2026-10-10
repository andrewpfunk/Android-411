# XRDP Authentication & Black Screen Fix (Android Debian Environment)

This guide documents the changes required to fix the `user droid does not exist or could not be authenticated` error and subsequent black screen issues following an environment update.

---

## 1. Groups & Permissions Fix

XRDP requires the user to belong to the `ssl-cert` group to handle secure connections. Re-add the user to restore permissions:

```bash
sudo adduser droid ssl-cert
```

---

## 2. Bypass Broken Android PAM (Authentication Failures)

Android blocks standard Linux PAM modules from accessing strict system files. We bypass this by setting authentication, account, and session policies to `pam_permit.so`.

**File:** `/etc/pam.d/xrdp-sesman`

Modify the file to look exactly like this:

```text
#%PAM-1.0
auth     required  pam_env.so readenv=1
auth     required  pam_env.so readenv=1 envfile=/etc/default/locale
#@include common-auth
auth required pam_permit.so
-auth    optional  pam_gnome_keyring.so
-auth    optional  pam_kwallet5.so

#@include common-account
account required pam_permit.so

@include common-password

#@include common-session
session required pam_permit.so
-session optional  pam_gnome_keyring.so auto_start
-session optional  pam_kwallet5.so auto_start
```

---

## 3. Clear Environment Conflicts & Launch XFCE

Forced container updates can cache stale D-Bus and XDG environment variables, breaking the connection to the window manager. Unset them and wrap the desktop session in a clean D-Bus sandbox.

**File:** `/etc/xrdp/startwm.sh`

Modify the bottom section of the file:

```bash
# Clean up conflicting paths causing the black screen
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR

# Comment out default session configurations
# test -x /etc/X11/Xsession && exec /etc/X11/Xsession
# exec /bin/sh /etc/X11/Xsession

# Launch XFCE cleanly
exec dbus-run-session -- xfce4-session
```

Keep your local configuration matching this strategy:
```bash
echo "dbus-run-session -- xfce4-session" > ~/.xsession
```

---

## 4. X11 Wrapper Display Permissions

Allow XRDP's Xorg backend to construct virtual framebuffers inside the Android layer without relying on root console access.

**File:** `/etc/X11/Xwrapper.config`

Set or add this line to the top of the file:

```text
allowed_users=anybody
```

---

## 5. Clean Flush & Global Service Restart

To fully apply these changes, background daemons on Android must be aggressively killed and restarted. Closing the app window does not kill background loops.

```bash
# Clear dead locks and cached session files
sudo rm -rf /tmp/.X*-lock /tmp/.X11-unix/X* /tmp/.xorgxrdp.*
rm -rf ~/.cache/sessions/*

# Hard restart the XRDP process architecture
sudo service xrdp stop
sudo pkill -9 xrdp
sudo pkill -9 xrdp-sesman
sudo pkill -u droid xfce4-session
sudo service xrdp start
```
