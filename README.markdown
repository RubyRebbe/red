Red is an object oriented design editor written in Ruby Tk.

The visual notation is simple and uniform, and came out of my dissatisfaction with UML having so many different diagram types.  I came to the conlusion that I could create a single diagram type capable of displaying both static and dynamic object model information at the various levels of analysis and design - from use case and user interface down to object interactions within the computer.  And thereby dispense with all of UML.  I call this notation UON:  Universal Object Notation.

I eat my own dog food!  I have successfully used UON for almost a decade to design software.  The first implementation of this UON editor was in Java AWT/Swing, which I later ported to C#.  The implementation before you is written in Ruby with the GUI stuff handled by Tk.

How to launch the editor: execute ./uonEditor.rb from the command line.

About the GUI:

There is no menu bar.  There are two pop-up menus.  If you click in empty space, you will see the application menu. If you click on an object, you will see the object menu.  That's it.
