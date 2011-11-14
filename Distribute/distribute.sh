#written by xhan Nov 14, 2011
# this is a dirty version to automatic distribute app version

DISGRIBUTE="/Users/less/Codes/xhan/LessDJ/Distribute"
CODE_SIGN="/Users/less/Codes/Shared.Codes/Sparkle 1.5b6/Extras/Signing Tools/sign_update.rb"
PRIVAET_KEY_PATH="$DISGRIBUTE/dsa_priv.pem"
REMOTE_PATH="ixhan@bayhawks.dreamhost.com:~/ixhan.com/app/lessdj"


root="/Users/less/Codes/xhan/LessDJ"
cd $root

build=$(git shortlog | grep -E '^[ ]+\w+' | wc -l)
build=$(ruby -e "puts \"$build\".to_i.to_s")
plist="$root/LessDJ/LessDJ-Info.plist"
version=$(ruby $DISGRIBUTE/get_display_version.rb $plist)
# write build number to plist file
ruby "$root/Distribute/change_version.rb" $plist $build


appcast_cfg="template.xml"
appcast_cfg_template="$DISGRIBUTE/${appcast_cfg}"



foldname="$version.$build"
filename="LessDJ_v$version.$build.tar.gz"
target_folder="$DISGRIBUTE/$foldname"

if [ ! -d $target_folder ]; then
	echo "make distribute folder"
	mkdir $target_folder
fi
filepath="$target_folder/$filename"
appcast_target="$target_folder/lessdj_appcast.xml" 

# build
# build path /Users/less/Codes/xcode-builds/Release
xcodebuild clean build

echo "archiving file..."
cd /Users/less/Codes/xcode-builds/Release
tar -czf $filepath "LessDJ.app"

echo "sign archive file.."
h=$(ruby "$CODE_SIGN" $filepath "$PRIVAET_KEY_PATH")
size=$(stat -f%z $filepath)

d=$(date +"%a, %d %b %G %T %z")

release_notes_name="releasenote_LessDJ_v$version.$build.html"
release_notes_file="$target_folder/$release_notes_name"


cat ${appcast_cfg_template} > $appcast_target
perl -p -i -e "s,<FILE_NAME>,$filename,g" $appcast_target
perl -p -i -e "s,<RELEASE_NOTES_NAME>,$release_notes_name,g" $appcast_target
perl -p -i -e "s,<VERSION>,$build,g" $appcast_target
perl -p -i -e "s,<SHORT_VERSION>,$version,g" $appcast_target
perl -p -i -e "s^<DATE>^$d^g" $appcast_target
perl -p -i -e "s,<HASH>,$h,g" $appcast_target
perl -p -i -e "s,<SIZE>,$size,g" $appcast_target

cp "$DISGRIBUTE/ReleaseNotesTemplate.html"  $release_notes_file
perl -p -i -e "s,<SHORT_VERSION>,$version,g" $release_notes_file

