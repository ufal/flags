


all: update release



# update README.md flaglist
# generate big flags image
# generate flagcoordinates.less file
update: release_files
	perl scripts/generate.pl --yaml "flags/codes_and_flags.yaml" --image_dir "flags/png" --icon_file "release_files/language-icons.png" --less_file "release_files/languageIconCoords.less"

release_files:
	mkdir release_files

# add less file and icons file to pmltq-web repository
release: perl-pmltq-web update
	cd perl-pmltq-web && git pull

	cd perl-pmltq-web && git commit . #TODO commit onli changed files

perl-pmltq-web:
	git clone git@github.com:ufal/perl-pmltq-web.git

install_deps:
	cpanm YAML::Tiny Text::MarkdownTable Image::Size

clean:
	rm -r perl-pmltq-web