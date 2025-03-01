Purpose
======

It has been the experience of those hopeful of using "[enterprise](https://www.ablison.com/what-does-enterprise-level-mean/)
level" Open Source Software on a home/ small office budget while using "RAID" technology that the promise of
recovery from a hardware failure is great, but when the hardware actually fails, recovery simply
doesn't work.

If you are considering the [BigRig Scripts](https://github.com/Romaq/bigrig-scripts/) project as a template
for setting up your own home or small office, I strongly suggest you consider testing your equipment for
backup recovery in the event of hardware failure. As my boss once told me, "Spit into one hand and *shhh-ould*
into the other, and see which of your hands fills faster." That zfs drive recovery "should" work simply isn't
good enough. Prove it does.

Todo
======
I note here there testing should be done to simulate live errors on a single drive and verify the behavior of ZFS towards
notifying admin, simulating the replacement of the "failed" drive by reformating and replacing it in the array, and the
full recovery process. I plan to test this at a later date according to the "simulated hardware failure" link mentioned
below.

Testing
======
Initially, I considered incorporating a [simulated hardware failure](https://stackoverflow.com/questions/1361518/how-can-i-simulate-a-failed-disk-during-testing)
to test. Unfortunately, my expertise is not at the level for activating fault injection code into the kernel.
It is also not my intent to recompile the kernel of Proxmox, nor have tools for doing so in place. The PVE
machine needs to be in a state of "as little change as possible to accomplish the purpose" according to my
rules as stated on the [Organization](../main/ORGANIZATION.md) for this
project: "Don't do *anything* unless it is required to fulfill the mission." That said, I do welcome expertise
on how to simulate drive failure through software of a live PVE machine as directly as possible and *only*
pertaining to the event of a single drive failure in the SATA array.

Instead, and perhaps just as well, is simulating a drive failure by simply "yanking" one of the SATA drives in
the RAIDz array. While it was suggested I do so with the physical PVE host active, I am very reluctant to do
so for several reasons:
1. It was reported to me physically pulling a single "live" drive in the array momentarily shuts down all drives
   in the array. I do not know for certain how zfs will react to that, and if it might consider all the drives
   in the array "dead." If zfs does, I'm in the situation where all drives are lost, which tells me nothing of
   what I'm attempting to know of the event of a single drive failure I *hope* to recover from.
2. I am not a hardware engineer with the technical understanding of how much to "trust" pulling a live drive
   out while powered and active will *NOT* physically harm the drive. At the risk of being accused a coward, I
   am simply unable to afford replacing the hard drive should pulling it "live" cause harm. While I am assured
   by others that it is "highly unlikely" to cause damage to the hardware, the cost of the "highly unlikely"
   happening is way beyond my budget. Cowardly or not, I reject the risk unless somebody *ELSE* is willing to
   foot the bill of what is, to me, a high-stakes odds game.

While considering my options, [Kingneutron](https://forum.proxmox.com/members/kingneutron.223146/) made the
following [suggestion](https://forum.proxmox.com/threads/zfs-advice.147358/#post-665953) The advice approaches
the perspective of taking the drive offline while the machine is running. Since I'm going to power the machine
down anyway to pull the physical drive from the USB Bay SATA array, I'm going to simply power down the PVE
host, pull either "/dev/sdb" or "/dev/sdd", power the PVE host back up, and see what it does. The SATA Array
hardware does not provide a means to determine the logical order of the array, so by pulling "in the middle
but definitely *not* the center," I hope to confirm what is, at the moment, only a guess as to the logical
orientation. I'm expecting the SATA array to function under ZFS, that it will report a drive "missing", and
I'm expecting (given my current set-up) it will email me the hardware failure. I will then confirm writing
a sizable block of an image to the degraded array, and then confirm the recovery steps Kingneutron suggests
while confirming zfs instructs me to do the same, and that the recovery steps work. I will also verify the
large image written to the drive in the degraded mode functions as expected.

I did not receive a warning email as expected. At this stage, I am still working on the specific "setup
configuration". As this specific hardware test passed, I am comfortable with repeating the test at a further
stage of development to ensure *if* the hardware fails on one of the SATA drives, I *will* be sent an email
warning by the PVE host.

First Test
------
Now to the specifics of the simulated hardware failure. `zpool status -P` returns the following information:
```
  pool: rpool
 state: ONLINE
  scan: scrub repaired 0B in 00:00:09 with 0 errors on Sun May 12 00:24:10 2024
config:

        NAME                                                               STATE     READ WRITE CKSUM
        rpool                                                              ONLINE       0     0     0
          /dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b4cca6d45-part3  ONLINE       0     0     0

errors: No known data errors

  pool: tank
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: scrub repaired 0B in 00:00:02 with 0 errors on Sun May 12 00:24:15 2024
config:

        NAME                      STATE     READ WRITE CKSUM
        tank                      DEGRADED     0     0     0
          raidz1-0                DEGRADED     0     0     0
            /dev/sda1             ONLINE       0     0     0
            16009700495985350329  FAULTED      0     0     0  was /dev/sdb1
            /dev/sdb1             ONLINE       0     0     0
            /dev/sdc1             ONLINE       0     0     0
            /dev/sdd1             ONLINE       0     0     0

errors: No known data errors
```
On the SATA array as viewed from the side of the drives plugged in (and the writing on the bay is face up),
the "Target 3" light is out until the entire array spins down to "sleep", in which case all lights go out
as expected. I note the drives are assigned letters right-to-left, so the pulled drive was labled `/dev/sdb`,
although that namespace has been reassigned to the middle drive. I also note ZFS is fussy to specify drives
by a "drive ID," noted here as a number that appears to be decimal 16009700495985350329. I note the hex value
for that decimal number is DE2D E1C7 2F9A 16B9. I also note "/dev/disk/by-partlabel/zfs-################" in
the existing `/dev/disk/by-partlabel` directory. I recall in my reading that zfs maintains drive identity to
a unique serial number rather than by device position. In a future test, I will verify I can remove one drive
while swapping sevral others, and the array should work fine: drive physical placement in the array is not
significant to zfs pool.

I have already selected several images to write to /tank in the degraded status. Now to power down PVE,
replace the drive, and set about recovery, then verify the images are unchanged.
```
# zpool status -P
  pool: rpool
 state: ONLINE
  scan: scrub repaired 0B in 00:00:09 with 0 errors on Sun May 12 00:24:10 2024
config:

        NAME                                                               STATE     READ WRITE CKSUM
        rpool                                                              ONLINE       0     0     0
          /dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b4cca6d45-part3  ONLINE       0     0     0

errors: No known data errors

  pool: tank
 state: ONLINE
  scan: resilvered 256K in 00:00:01 with 0 errors on Tue May 21 10:56:21 2024
config:

        NAME           STATE     READ WRITE CKSUM
        tank           ONLINE       0     0     0
          raidz1-0     ONLINE       0     0     0
            /dev/sda1  ONLINE       0     0     0
            /dev/sdb1  ONLINE       0     0     0
            /dev/sdc1  ONLINE       0     0     0
            /dev/sdd1  ONLINE       0     0     0
            /dev/sde1  ONLINE       0     0     0

errors: No known data errors
```
And "resilvering" was both automatic and practically instant. I just brought the machine online and I
didn't have time to see the drive in a degraded state before it was recovered! I also note the serial
number provided by `zpool status -P` does not match anything I see currently in `/dev/disk`. But given
the process, zfs "just handled it," and I'm not going to focus on something I can't do anything about.
I *expect* if I replaced the failed drive with an entirely new drive, I would have to tell zpool to
accept that new drive into the array. Without the replacement drive, I simply cannot verify this. But
someone who has such a drive available *should* verify this, and I would be happy to include their work
in this document with credit.

The only wrinkle remaining is to have the PVE host email a warning as it detects a drive failure. The
warning email does show in `/var/spool`, but I also had problems with connectivity with PVE and hosts.
My router also reset, and I will need to sort out resetting the host when the router does an update or
resets. The "warning" system worked, although receipt of that warning is a flaw with other systems not
in the context of this document.

Second Test
-----
On client request, I pulled the middle drive "hot." The zpool immediately went into suspension, and an
attempt caused the terminal to lock although I could close it and make a new terminal. There is no
means to [unsuspend](https://github.com/openzfs/zfs/issues/5242) the zpool, and my attempt to power it
off failed since the system could not unmount the drive. I had to hard-power it down. While the PVE
was powered off, I swapped the drive on the end into the vacancy in the middle, then I powered the PVE
back on. The drive came back up degraded, but I could fully read and write the drive in the degraded
condition. I then placed the "simulated dead" drive back into the open slot while the array was hot.
This caused the zpool to become suspended again, requiring another physical power-down. I did not take
the time to reformat the "simulated dead" drive to be able to return an answer quickly to the client.

As hoped, on reboot the replaced drive resilvered before I had opportunity to get online and verify
the "degraded" condition of the array. In any future test, the drive will need to be reformatted or
an actually new drive will need to be put into the array.
