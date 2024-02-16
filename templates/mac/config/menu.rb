ObjRuby::NSMenu.shared.draw do
  menu do
    item "About", "orderFrontStandardAboutPanel:"
    separator
    item "Quit", "terminate:", "q"
  end
end
