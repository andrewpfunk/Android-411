# Android-411
My favorite Android apps and things to try

## My phones

In 2007 Apple introduced the iPhone and revolutionized the smartphone industry. While the original is still arguably the best, I'll always prefer the flexibility to customize and experiment that Android provides.

| Year | Phone | Features |
|---|---|---|
| 2008 | MOTO RIZR Z6tv | Watch TV on a tiny screen |
| 2010 | Droid 2 | Slide-out keyboard |
| 2012 | Droid Incredible | Honestly I don't remember this phone |
| 2014 | Galaxy S5 | More well established than new Pixel line |
| 2016 | Galaxy S7 |  |
| 2019 | Galaxy S10 | |
| 2022 | Galaxy S22 | Had superior 3x zoom lense that year |
| 2025 | Pixel 10 | Superior 5x zoom lense, plus Linux and VPN |

## My favorite apps

Over the years these are the apps I keep installing on new phones

| App | Category | Notes |
|---|---|---|
| Alarm Clock Xtreme | Alarm clock | Goofy name but elegant design with extensive customization |
| Bitwarden | Password manager | |
| Calendar (Google) | Calendar ||
| Chrome (Google) | Web browser ||
| DevCheck | Device info | |
| DiskUsage | Disk usage | No longer maintained but still my favorite visualization |
| Drive (Google) | Cloud storage | |
| droidVNC-NG | VNC server | I just found this recently but it works great; previously used scrcpy |
| eBoox | eBook reader | |
| Gmail | Email client | |
| LibreTorrent | BitTorrent client | |
| Maps (Google) | Maps and Navigation | |
| Messages (Google) | Messages | |
| Musicolet | Music player | Extensive playlist and queue management |
| NewPipe | YouTube client | |
| Photos (Google) | Cloud photo storage | |
| Pocket Casts | Podcast player | |
| RealCalc | Calculator | |
| Slopes | Ski tracker | |
| Termux | Linux terminal | More users and better support than Android 16 Linux Terminal |
| theScore | Sports scores | |
| Todoist | Task tracker | Transparent widget, cloud sync, full-featured task management |
| VLC | Video player | |
| Your Calendar Widget | Calendar widget | Transparent, fully-customizable widget |

## droidVNC-NG

Mirror your screen and control your phone from your computer

### Special keys

| Computer | Android |
|---|---|
| Esc | Back |
| fn + left | Home |
| fn + right | Power |
| Ctrl + Shift + Esc | Recent apps |

## Linux Terminal

Although Termux works very well, I was curious to try out the Linux Terminal that comes with Android 16. 

```
droid@localhost:~$ hostnamectl
  Operating System: Debian GNU/Linux 12 (bookworm)  
            Kernel: Linux 6.1.0-34-avf-arm64
      Architecture: arm64
```

### Font

The first thing I noticed is that the font is hard to read. There doesn't appear to be any way to change it in app settings. After some trial and error with Pixel settings, I decided to keep the Font size at one notch (default) but increase the Display size from one (default) to two notches. Still, the font used in Terminal is not easy on the eyes. Given that the Termux font looks fine, I think this is just a poor choice of font on Google's part, something which they will probably fix eventually.

### File transfer

Files can be copied between Android and the Linux Terminal using these folders:

- Android: ```/storage/emulated/0/Download``` aka Downloads
- Linux Terminal: ```/mnt/shared```

### ssh

The font issue, together with the limited screen size and lack of a physical keyboard, made me want to connect to the Linux Terminal from my computer using ssh. This also took some trial and error but I eventually got it working. Using droidVNC-NG made the process easier by allowing me to type commands in the Linux Terminal app with my computer's keyboard before I got ssh working. 

As a first step, make sure your computer and phone are on the same Wi-Fi network and can talk to each other, e.g.

```
$ ping pixel-10
PING pixel-10 (192.168.1.185): 56 data bytes
64 bytes from 192.168.1.185: icmp_seq=2 ttl=64 time=55.449 ms
```

#### ssh server

Next we need to install an ssh server. Before installing software packages it is recommended to run:

```sudo apt get update && sudo apt get upgrade```

Then run:

```sudo apt install openssh-server```

The Terminal app does not allow forwarding port 22 (more on port forwarding below) so we need to configure sshd to use a different port (I chose 8022).

🚧 did we need to install pico or nano?

```
$ sudo pico /etc/ssh/sshd_config
Port 8022   # change from Port 22
```

Now configure the server to start and run automatically with this command:

```sudo systemctl enable ssh```

🚧 at this point what happens when we run:

 ```
 $ ssh localhost -p 8022
 ```

#### Password login

By default, the Linux Terminal logs in as user droid, which is not set up for password login. So, even though the ssh server is now running, if we try to ssh locally it will say:

🚧 (what does it say? - connect to previous section)

Show before and after result of passwd --status, ssh@localhost

I've seen a few different recipes for adding password login to the droid user. This is what worked for me:

```
sudo su -           # become root
sudo passwd droid
                    # enter a new password
exit
```

In theory we could also use ssh keys but I stopped when I got password login working.

#### Port forwarding

Tap on the settings icon for Terminal, select Port control, press the + and enter port number 8022 (it won't let you enter 22).

Now we should at least be able to ssh to localhost over port 8022, like this:

```
droid@localhost:~$ ssh localhost -p 8022
droid@localhost's password: 
```

But this is not enough to allow ssh from another device, because as this user explains, "You can SSH into the VM with adb, but you cannot ssh in from the network (unless you use adb first) because the loopback adapter in the VM does not forward ports outside the device."

https://www.reddit.com/r/AndroidQuestions/comments/1nl869m/new_terminal_a_full_linux_vm_can_i_ssh_into_it/


### adb

If you don't already have adb on your computer, install the Android Platform Tools from this or another location:
https://developer.android.com/tools/releases/platform-tools

Then follow these instructions to set up Wireless debugging:
https://developer.android.com/tools/adb

Run the following command to confirm that you are connected to your phone with adb:

```
$ adb devices
List of devices attached
adb-59051FDCR0054L-lpsvGQ._adb-tls-connect._tcp	device   # YMMV
```

Now run the following command to forward port 8022 from your computer to your phone:

```
adb forward tcp:8022 tcp:8022
```

Finally, you should be able to connect using this command:

```
ssh droid@localhost -p 8022
droid@localhost's password: 
```

🚧 XC: xeyes



