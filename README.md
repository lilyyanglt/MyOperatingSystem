# Building a simple operating system

Personal project trying to build an operating system from the ground by following the [Nick Blundell's book](https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf) and also using resources from the Princeton course COS318. Although he hasn't completed the book, but it's a great resource to learn more about the system.

My goal is to learn enough from this book and then start building on top of it with other features.


# Important note

* When compiling the image by running `cat boot_sect.bin kernel.bin > os-image`
* the order is very important, if you switched the order of kernel.bin and then boot_sect.bin in your os-image, the first sector would be the kernel, 
* so you'll run into the issue of boot disk not found.