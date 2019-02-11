release_icons=release_files/language-icons.png
release_less=release_files/languageIconCoords.less
rep=perl-pmltq-web
pmltq_icons=app/treebank/directives/language-icons.png
pmltq_less=app/treebank/directives/languageIconCoords.less



all: update release



# update README.md flaglist
# generate big flags image
# generate flagcoordinates.less file
update: release_files
	perl scripts/generate.pl --yaml "flags/codes_and_flags.yaml" --image_dir "flags/png" --icon_file "$(release_icons)" --less_file "$(release_less)"

release_files:
	mkdir release_files

# add less file and icons file to pmltq-web repository
release: $(rep)
	cd $(rep) && git pull
	test -s "$(rep)/$(pmltq_icons)" || { echo "$(pmltq_icons) does not exist! Exiting..."; exit 1; }
	test -s "$(rep)/$(pmltq_less)" || { echo "$(pmltq_less) does not exist! Exiting..."; exit 1; }
	cp -f $(release_icons) "$(rep)/$(pmltq_icons)"
	cp -f $(release_less) "$(rep)/$(pmltq_less)"
	cd $(rep) && git commit $(pmltq_icons) $(pmltq_less)
	cd $(rep) && git push

perl-pmltq-web:
	git clone git@github.com:ufal/perl-pmltq-web.git

install_deps:
	cpanm YAML::Tiny Text::MarkdownTable Image::Size

clean:
	rm -rf $(rep)
	rm -rf release_files