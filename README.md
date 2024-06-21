<h1>KCalc -- a Lua-based, console expression evaluator and math library</h1> 

Version 9.0.0, January 2023

<p>
<b>
Please note that this program is not connected in any way with the 
KDE utility of the same name. I've been maintaining 'kcalc' since before
there was a KDE, and I'm not going to change the name.
</b>
</p>

<table align="center" width="30%" border="1" cellpadding="5">
<tr>
<td>
Please note that this is a work in progress. Not all the functionality
of the previous versions has yet been ported to version 9. The function
library is not stable, and new functions are being added regularly.
Note that this version can no longer be built as a native
Windows console application, because I'm not sure that the tools 
for such a build still exist. Although primariy intended for Unix-like
systems, it will build for Windows under Cygwin, and the Windows
Subsystem for Linux (with the appropriate dependencies). 
</td>
</tr>
</table>

<h2>What is this?</h2>

<i>KCalc</i> is a command-line expression evaluator and 
math library based on the 
Lua programming language. It is implemented partly in Lua and partly
in C. <i>KCalc</i> is designed to occupy a place between simple 
pocket calculator-type applications, and heavyweights like Octave and
Matlab. Like the heavyweights it has full support for complex numbers,
and is extensible with scripts (in this case, using the Lua language). 
Unlike them, it
consumes less than a megayte of storage and neglibible RAM, and 
starts up very quickly even on low-powered platforms. 
<p/>
<i>KCalc</i> is a console (command-line) application, and should run on
any platform that can provide a GNU C compiler and a prompt. However, 
it is primarily intended for Linux. 
It provides line editing
and history support via the GNU <i>Ireadline</i> library, on platforms
that support it (Cygwin and most unix-like environments do).
<p/>
To use <i>KCalc</i> as a calculator requires no knowledge of Lua 
programming -- it is completely self-contained. However, to add
new functionality does require at least a rudimentary understanding of
Lua. To solve complicated math problems really requires an extensive 
understanding of Lua.
<p/>
KCalc is supplied with a modest function library, providing support
for basic trigonometry, equation solving, statistical, financial, and
file-handling operations. This can easily be extended.

<h2>Building and installation</h2>

Binaries of <i>KCalc</i> are available for various Linux platforms in software
repositories. However, these might not be up to date, and building 
from source is alawys recommended.
In most cases cases, this ought to be no more complicated
that unpacking the source bundle, and running

<pre>
$ make
</pre>

and then

<pre>
$ sudo make install 
</pre>

<h2>Author and legal</h2>

<i>KCalc</i> is maintained by Kevin Boone, and distributed under the terms
of the GNU Public Licence, v3.0. Essentially, this meams that you may 
use this software as you wish, at your own risk, provided that the 
original author continues to be acknowledged.
<p/>
Please report bugs, etc., through GitHub. 

