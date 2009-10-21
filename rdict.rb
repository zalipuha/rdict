#!/usr/bin/ruby
require "gtk2"
require "open3"
def translation(text=nil)
  w = Gtk::Window.new
  x,y,push_in = $tray.position_menu(Gtk::Menu.new)
  w.move(x,y)
#  w.transient_for=$tray
#  w.resize(300,300)
  w.stick
  w.decorated = false
  w.keep_above = true
  text=$buffer.wait_for_text if text.nil?
  text.gsub!(/\d+/,' ')
  text.gsub!(/-\s*\n/,'')
  text.gsub!(/[^a-zA-Z]/,' ')
#  out=`dict #{text}`
  input,out,err=Open3.popen3 "dict #{text}"
  out=out.readlines.join
  err=err.readlines.join
  if not out.empty?
    w.add(Gtk::Label.new(out))
  elsif err=~/^No definitions found for/ and err=~/perhaps you mean:/
    err.gsub! /^.*:/,""
    box=Gtk::VBox.new
    box.add Gtk::Label.new("Может по другому?")
    suggest=err.split /\s/
    suggest.delete ""
    suggest.each { |variant| 
      button=Gtk::Button.new variant
      button.signal_connect('clicked') { |click|
          w.destroy
          translation variant
        }
      box.add button
    }
    w.add box
  else
    w.add(Gtk::Label.new("Мяяяу??!"))
  end
  w.add_events(Gdk::Event::FOCUS_CHANGE)
    w.signal_connect('focus-out-event') {|w, e| w.destroy}
  w.show_all
end

$tray=Gtk::StatusIcon.new
$tray.file="/usr/local/share/rdict/cat.gif"
$tray.tooltip="Жмакни на кошку, что-нибудь да и появится!"
$buffer=Gtk::Clipboard.get(Gdk::Selection::PRIMARY) 
$tray.signal_connect('activate') {
  translation
}
Gtk.main

