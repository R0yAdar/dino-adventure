# dino-adventure
Silly 16bit asm (8086) implementation of Google's Dino Game &amp; Tetris, that I wrote as a 10th grade final project for my cyber class.
Uploaded now because I've just realized I have no backup of it and I'm quite fond of it.

If I remember correctly to run it you just need to compile Main.asm and link it using TASM & TLINK (the other files are just included in Main.asm).
Afterwards you can run it using the DosBox emulator.

The dino game was created before the Tetris one, and it has its design flaws (e.g. each character has a custom proc of semi-auto-generated custom assembly code that draws it line by line <---- pretty silly way to increase binary size, but at least effective maximizing performance? idk. dependes on cache lines. oh just checked and the 8086 didn't have L1/L2/... honestly bold of my to semi-assume that, it did have next instruction prefetch though. Nevertheless, it seems that I was right and it is at least faster ;) 

The Tetris one was created after a friend told me that another student is making the Tetris game and it is much harder to do than dino, blah blah blah blah
So I pulled an all nighter, wrote Tetris and added it to the project, wow I miss these times.
The Tetris game has a much cleaner and shorter implementation (with some clever tricks) and because of that I kept most of the code seperate, adding a T prefix to some files.

I can't help but feel that I just wrote a diary entry into my GitHub. But honestly? it's pretty funny so I'll keep it that way.

It's 1:28 AM 4.5.2026, the game was finalized around june 2021. I'm heading to finish watching Mad Men S5E06, good night.

<img width="640" height="400" alt="ezgif-157b505752f59cd4" src="https://github.com/user-attachments/assets/c57f1ba7-3d45-4f71-b941-4261f153e6d9" />
<img width="640" height="400" alt="dinogif" src="https://github.com/user-attachments/assets/b3a8c942-b1dc-4a26-a151-e4025a1e6761" />
