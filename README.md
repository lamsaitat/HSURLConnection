HSURLConnection
===============

A convenient URL Connection wrapper class that lets you abuse block coding with.

This class is written based on http://github.com/0xSina/URLConnection
So if any credits, it should go to 0xSina, I just modified the code to prevent duplicate connections, and give an ARC compliant implementation.



How to use:
* It's straight forward enough to use pretty much the same way as NSURLConnection
1. Read TASViewController.m - under - viewDidLoad.
2. Read iOS Documentation (iOS 5+) and learn how NSURLConnection works, then read 1.

Final words:
* I have only one condition for usage, as soon as you start modifying the code, rename the class and don't even mention my name anywhere, you touch it, it's your code, not mine anymore.
* I don't care about licencing, use it and modify it at your own risk, as soon as you use any of my implementations you forfeit any rights to sue me due to the use of this code.
* Please don't ask me to support anything below iOS 5, if Apple stopped supporting this OS version, so should you.
* I don't mind you coding without ARC, don't you mind me coding with ARC.
