#!/bin/bash
# Prepare Propel tests by building fixtures
# 2011 - William Durand <william.durand1@gmail.com>

if [ 0 == $# ] ; then
    DATABASE_VENDOR="mysql"
    DATABASE_USER="root"
    DATABASE_PASSWORD=""
else

    set -- $(getopt -c $0 vendor:user:password "$@")

    while [ $# -gt 0 ] ; do
        case $1 in
            --vendor)
                shift;
                DATABASE_VENDOR="$1";
                ;;
            --user)
                shift;
                DATABASE_USER="$1";
                ;;
            --password)
                shift;
                DATABASE_PASSWORD="$1";
                ;;
            (--)
                ;;
            (-*)
                echo "$0: Error - unrecognized option $1" 1>&2;
                exit 1;;
            (*)
                ;;
        esac
        shift
    done
fi

echo "=========================================="
echo "Vendor   : $DATABASE_VENDOR"
echo "User     : $DATABASE_USER"
echo "Password : $DATABASE_PASSWORD"
echo "=========================================="
echo

CURRENT=`pwd`

function rebuild
{
    local dir=$1

    echo "[ $dir ]"

    if [ -f $FIXTURES_DIR/$dir/build.properties ] ; then
        rm "$FIXTURES_DIR/$dir/build.properties"
    fi

    if [ -f $FIXTURES_DIR/$dir/runtime-conf.xml ] ; then
        rm "$FIXTURES_DIR/$dir/runtime-conf.xml"
    fi

    if [ -f $FIXTURES_DIR/$dir/build.properties.dist ] ; then
        cp $FIXTURES_DIR/$dir/build.properties.dist $FIXTURES_DIR/$dir/build.properties

        sed -i -e "s/##DATABASE_VENDOR##/`echo $DATABASE_VENDOR`/g" "$FIXTURES_DIR/$dir/build.properties"
        sed -i -e "s/##DATABASE_USER##/`echo $DATABASE_USER`/g" "$FIXTURES_DIR/$dir/build.properties"
        sed -i -e "s/##DATABASE_PASSWORD##/`echo $DATABASE_PASSWORD`/g" "$FIXTURES_DIR/$dir/build.properties"
    fi

    if [ -f $FIXTURES_DIR/$dir/runtime-conf.xml.dist ] ; then
        cp $FIXTURES_DIR/$dir/runtime-conf.xml.dist $FIXTURES_DIR/$dir/runtime-conf.xml

        sed -i -e "s/##DATABASE_VENDOR##/`echo $DATABASE_VENDOR`/g" "$FIXTURES_DIR/$dir/runtime-conf.xml"
        sed -i -e "s/##DATABASE_USER##/`echo $DATABASE_USER`/g" "$FIXTURES_DIR/$dir/runtime-conf.xml"
        sed -i -e "s/##DATABASE_PASSWORD##/`echo $DATABASE_PASSWORD`/g" "$FIXTURES_DIR/$dir/runtime-conf.xml"
    fi

    if [ -d "$FIXTURES_DIR/$dir/build/" ] ; then
        rm -rf "$FIXTURES_DIR/$dir/build/"
    fi

    $ROOT/tools/generator/bin/propel-gen $FIXTURES_DIR/$dir main
    $ROOT/tools/generator/bin/propel-gen $FIXTURES_DIR/$dir insert-sql
}

ROOT_DIR=""
FIXTURES_DIR=""

if [ -d "$CURRENT/Fixtures" ] ; then
    ROOT=".."
    FIXTURES_DIR="$CURRENT/Fixtures"
elif [ -d "$CURRENT/tests/Fixtures" ] ; then
    ROOT="."
    FIXTURES_DIR="$CURRENT/tests/Fixtures"
else
    echo "ERROR: No 'tests/Fixtures/' directory found !"
    exit 1
fi

DIRS=`ls $FIXTURES_DIR`

for dir in $DIRS ; do
    if [ -f $FIXTURES_DIR/$dir/schema.xml ] ; then
        rebuild $dir
    fi
done

# Special case for reverse Fixtures
REVERSE_DIRS=`ls $FIXTURES_DIR/reverse`

for dir in $REVERSE_DIRS ; do
    echo "[ $dir ]"

    if [ -f $FIXTURES_DIR/reverse/$dir/build.properties ] ; then
        rm "$FIXTURES_DIR/reverse/$dir/build.properties"
    fi

    if [ -f $FIXTURES_DIR/$dir/runtime-conf.xml ] ; then
        rm "$FIXTURES_DIR/reverse/$dir/runtime-conf.xml"
    fi

    if [ -f $FIXTURES_DIR/reverse/$dir/build.properties.dist ] ; then
        cp $FIXTURES_DIR/reverse/$dir/build.properties.dist $FIXTURES_DIR/reverse/$dir/build.properties

        sed -i -e "s/##DATABASE_VENDOR##/`echo $DATABASE_VENDOR`/g" "$FIXTURES_DIR/reverse/$dir/build.properties"
        sed -i -e "s/##DATABASE_USER##/`echo $DATABASE_USER`/g" "$FIXTURES_DIR/reverse/$dir/build.properties"
        sed -i -e "s/##DATABASE_PASSWORD##/`echo $DATABASE_PASSWORD`/g" "$FIXTURES_DIR/reverse/$dir/build.properties"
    fi

    if [ -f $FIXTURES_DIR/reverse/$dir/runtime-conf.xml.dist ] ; then
        cp $FIXTURES_DIR/reverse/$dir/runtime-conf.xml.dist $FIXTURES_DIR/reverse/$dir/runtime-conf.xml

        sed -i -e "s/##DATABASE_VENDOR##/`echo $DATABASE_VENDOR`/g" "$FIXTURES_DIR/reverse/$dir/runtime-conf.xml"
        sed -i -e "s/##DATABASE_USER##/`echo $DATABASE_USER`/g" "$FIXTURES_DIR/reverse/$dir/runtime-conf.xml"
        sed -i -e "s/##DATABASE_PASSWORD##/`echo $DATABASE_PASSWORD`/g" "$FIXTURES_DIR/reverse/$dir/runtime-conf.xml"
    fi

    $ROOT/tools/generator/bin/propel-gen $FIXTURES_DIR/reverse/$dir insert-sql
done
