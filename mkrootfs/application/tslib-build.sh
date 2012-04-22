#!/bin/bash

appldir="tslib-1.0"
applurl=""

pkg_name=`basename ${applurl}`
pkg_full=${PACKAGE_PATH}/${pkg_name}
src_full=${SOURCES_PATH}/${appldir}

if [ ! -f ${pkg_full} ]; then
    wget --tries=10 --wait=5 --continue ${applurl} -P ${PACKAGE_PATH}
fi
echo -n "Extracting ${pkg_name} .... "
tar -xf ${pkg_full} -C ${SOURCES_PATH}
echo "Done."

cd ${src_full}
./configure \
    ac_cv_func_realloc_0_nonnull=yes \
    ac_cv_func_malloc_0_nonnull=yes \
    --host=${TARGET_HOST} \
    --prefix=${PREFIX_PATH} \
    || exit 1

make && make install || exit 1
cd -

