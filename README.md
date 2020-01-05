<h1>KCalc -- a Lua-based expression evaluator and math library</h1> 

Version 8.0, March 2013

<table align="center" width="30%" border="1" cellpadding="5">
<tr>
<td>
Please note that this is a work in progress. Not all the functionality
of the previous version has yet been ported to version 8. The function
library is not stable, and new functions are being added.
</td>
</tr>
</table>

<h2>What is this?</h2>

<i>KCalc</i> is an expression evaluator and math library based on the 
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
any platform that can provide a C compiler and a prompt. Versions
are available for Linux, Cygwin, the native Windows prompt ('DOS box'),
and for Android (using a terminal emulator). It provides line editing
and history support via the GNU <i>Ireadline</i> library, on platforms
that support it (Cygwin and most unix-like environments do; the Windows
console does not). 
<p/>
To use <i>KCalc</i> as a calculator requires no knowledge of Lua 
programming -- it is completely self-contained. However, to add
new functionality does require at least a rudimentary understanding of
Lua.
<p/>
KCalc is supplied with a modest function library, providing support
for basic trigonometry, equation solving, statistical, financial, and
file-handling operations.

<h2>Building and installation</h2>

Binaries of <i>KCalc</i> are available for various platforms in software
repositories. However, these might not be up to date, and building 
from source is alawys recommended.
In most cases cases, this ought to be no more complicated
that unpacking the source bundle, and running

<pre>
$ make build
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
Please report bugs, etc., through github. 

<h2>Further information</h2>

<a href="kcalc.man.html">KCalc man page</a><br/>
<a href="kcalc_faq.html">KCalc FAQ</a><br/>
<a href="http://www.lua.org/manual/5.2/">Lua 5.2 reference manual</a><br/>


