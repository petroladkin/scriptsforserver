echo $(curl http://www.joomla.org/download.html | sed -n '/Joomla_3/p' | tr "\"" "\n" | sed -n '/Package.zip$/p')
