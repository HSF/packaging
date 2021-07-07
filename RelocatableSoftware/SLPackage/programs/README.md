`hsfreloc` Programs
===================
`hsfreloc`
----------
Simple program showing self-location using `binreloc` C code. This
is generaly portable across UNIX platforms, but not yet native Windows.

On Win32, it looks like the [`GetModuleFileName`](http://msdn.microsoft.com/en-us/library/windows/desktop/ms683197%28v=vs.85%29.aspx) function can be
used to determine the full path to the file containing a given module.
If it's called with a `NULL` module handle, it will retrieve the path
to the executable of the current process. That can be used for programs.
For DLLs, it's mentioned that [DllMain](http://msdn.microsoft.com/en-us/library/windows/desktop/ms682583%28v=vs.85%29.aspx) can be used as this gets
passed a handle to the DLL module. That handle can be passed to
`GetModuleFileName`. **Note the warning** on the [MSDN Reference](http://msdn.microsoft.com/en-us/library/windows/desktop/ms682583%28v=vs.85%29.aspx)
about the limitations of what can be done in this entry point function!
Whilst a few years old now, MSDN's
[Best Practice for Creating Dlls](http://msdn.microsoft.com/en-us/windows/hardware/gg487379.aspx) discusses these limitations.
One recommendation seen is to store the module handle as static
data of the DLL, setting it in DllMain, and provide a public API that will
call GetModuleFileName using this handle.

`hsfreloc-poco`
---------------
Uses Poco's builtin `Application`class for self-location. This requires
Poco's [`Util`](http://pocoproject.org/docs/Poco.Util.html) library.
Should be portable to all of Poco's supported platforms.

The program does not go any further than self-location. The same
ideas/techniques as shown in `hsfreloc` can be used to derive
additional locations.

`hsfreloc-qt`
------------
Uses Qt5's [`QAaplication`](http://doc.qt.io/qt-5/qapplication.html) class
for program self-location. This requires Qt5's `QtCore` library.
Should be portable to all of Qt5's supported platforms.

The program does not go any further than self-location. The same
ideas/techniques as shown in `hsfreloc` can be used to derive
additional locations. Note that Qt also provides its own resource and
plugin system, so these can be used instead (and probably should
be preferred it Qt is in use anyway).



