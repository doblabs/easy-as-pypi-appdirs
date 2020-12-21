# This file exists within 'easy-as-pypi-apppth':
#
#   https://github.com/tallybark/easy-as-pypi-apppth#🛣
#
# Copyright © 2018-2020 Landon Bouma. All rights reserved.
#
# Permission is hereby granted,  free of charge,  to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge,  publish,  distribute, sublicense,
# and/or  sell copies  of the Software,  and to permit persons  to whom the
# Software  is  furnished  to do so,  subject  to  the following conditions:
#
# The  above  copyright  notice  and  this  permission  notice  shall  be
# included  in  all  copies  or  substantial  portions  of  the  Software.
#
# THE  SOFTWARE  IS  PROVIDED  "AS IS",  WITHOUT  WARRANTY  OF ANY KIND,
# EXPRESS OR IMPLIED,  INCLUDING  BUT NOT LIMITED  TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE  FOR ANY
# CLAIM,  DAMAGES OR OTHER LIABILITY,  WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE,  ARISING FROM,  OUT OF  OR IN  CONNECTION WITH THE
# SOFTWARE   OR   THE   USE   OR   OTHER   DEALINGS  IN   THE  SOFTWARE.

"""Public fixtures."""

import os

import pytest
from unittest import mock

from easy_as_pypi_apppth.app_dirs_with_mkdir import AppDirsWithMkdir
from easy_as_pypi_apppth.expand_and_mkdirs import must_ensure_directory_exists


def mocker_patch_app_dirs(mocker, tmpdir, which):
    prop_name = '{}_dir'.format(which)
    tmp_appdir = os.path.join(tmpdir.mkdir(which).strpath, 'easy-as-pypi-apppth')
    # Because mocking property, which is wrapped by @mkdir_side_effect, do same,
    # albeit preemptively. (lb): Seriously, such a smelly side effect.
    must_ensure_directory_exists(tmp_appdir)
    pkg_path = 'easy_as_pypi_apppth.app_dirs_with_mkdir.AppDirsWithMkdir'
    target = '{}.{}'.format(pkg_path, prop_name)
    mocker.patch(target, new_callable=mock.PropertyMock(return_value=tmp_appdir))


@pytest.fixture
def tmp_appdirs(mocker, tmpdir):
    """Provide mocked version specific user dirs using a tmpdir."""
    mocker_patch_app_dirs(mocker, tmpdir, 'user_data')
    mocker_patch_app_dirs(mocker, tmpdir, 'site_data')
    mocker_patch_app_dirs(mocker, tmpdir, 'user_config')
    mocker_patch_app_dirs(mocker, tmpdir, 'site_config')
    mocker_patch_app_dirs(mocker, tmpdir, 'user_cache')
    mocker_patch_app_dirs(mocker, tmpdir, 'user_state')
    mocker_patch_app_dirs(mocker, tmpdir, 'user_log')
    return AppDirsWithMkdir()

