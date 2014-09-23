function build_libmp3lame {
  echo "Building libmp3lame for android ..."

  # download lame
  lame_archive=${src_root}/lame-3.99.5.tar.gz
  if [ ! -f "${lame_archive}" ]; then
    test -x "$(which curl)" || die "You must install curl!"
    curl -L http://sourceforge.net/projects/lame/files/lame/3.99/lame-3.99.5.tar.gz/download -o ${lame_archive} >> ${build_log} 2>&1 || \
      die "Couldn't download lame sources!"
  fi

  # extract lame
  if [ ! -d "${src_root}/lame" ]; then
    cd ${src_root}
    tar xvzf ${lame_archive} >> ${build_log} 2>&1 || die "Couldn't extract lame sources!"
  fi

  # patch the Makefile to use an Android-friendly versioning scheme
  cp ${patch_root}/libmp3lame-Android.mk ${src_root}/lame-3.99.5/Android.mk
  cd ${src_root}/lame-3.99.5/libmp3lame
  cp ../include/lame.sh .
  patch -u set_get.h ${patch_root}/libmp3lame-set_get.patch >> ${build_log} 2>&1 || \
    die "Couldn't patch libmp3lame set_get.h!"
  patch -u util.h ${patch_root}/libmp3lame-util.patch >> ${build_log} 2>&1 || \
    die "Couldn't patch libmp3lame util.h!"

  cd ${src_root}/lame-3.99.5
  ${NDK}/ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk >> ${build_log} 2>&1 || die "Couldn't build libmp3lame!"

  # copy the versioned libraries
  cp ${src_root}/lame-3.99.5/libs/armeabi/lib*.so ${dist_lib_root}/.
  # copy the headers
  cp -r ${src_root}/lame-3.99.5/include/* ${dist_include_root}/.

  cd ${top_root}
}
