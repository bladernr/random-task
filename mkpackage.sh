#!/bin/bash
#
# Copyright (C) 2010-2011 Canonical
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#


#
# Get stress-ng sources, strip out .git directory, add in necessary debian packaging
# files, build source package ready for upload.
#
#RELEASES="trusty vivid xenial yakkety zesty"
RELEASES="xenial" # yakkety zesty"
REPO=git://kernel.ubuntu.com/cking/stress-ng
#REPO=../stress-ng
STRESS_NG=stress-ng

#
#  Clone the repo
#
get_source()
{
	echo Getting source
	git clone $REPO
	echo "3.0 (native)" > stress-ng/debian/source/format
}

#
#  Figure out latest tagged version
#
get_version()
{
	pushd $STRESS_NG >& /dev/null
	git tag | tail -1
	popd >& /dev/null
}

#
#  Checkout version
#
checkout_version()
{
	echo "Checking out version $1"
	pushd $STRESS_NG >& /dev/null
	git checkout -b latest $1
	popd >& /dev/null
}

#
#  Remove .git repo as we don't want this in the final package
#
rm_git()
{
	rm -rf $STRESS_NG/.git
}

#
#  Remove the source
#
rm_source()
{
	rm -rf $STRESS_NG
}

#
#  Create source package ready for upload and build
#
mk_package()
{
	rel=$1

	rm -rf $version/$rel
  	mkdir -p $version/$rel
	cp -r $STRESS_NG $version/$rel

	pushd $version/$rel/$STRESS_NG >& /dev/null

	#deb_topline=`head -1 debian/changelog`
	#deb_release=`echo $deb_topline | cut -f3 -d' '`
	#if [ "x$rel;" = "x$deb_release" ]; then
	#	suffix='~ppa'
	#else
	#	suffix="~`echo $rel | cut -c1`"
	#fi
	
	#	
	# Mungify changelog hack
	#
    dch -i "Bump for Cert PPA"
    sed "s/ubuntu1/~ppa/" debian/changelog > debian/changelog.new
	mv debian/changelog.new debian/changelog
    dch -r --distribution $rel ""

	uscan --download-current-version
	
  	echo 'y' | debuild -S
	rm -rf $STRESS_NG
	popd >& /dev/null
}


#
#  Here we go..
#
rm_source
get_source

if [ $# -eq 1 ]; then
	version=$1
else
	version=`get_version`
fi

checkout_version $version
rm_git

for I in $RELEASES 
do
	echo Building package for release $I with version $version
	mk_package $I
done

rm_source
