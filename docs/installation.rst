############
Installation
############

.. |virtualenv| replace:: ``virtualenv``
.. _virtualenv: https://virtualenv.pypa.io/en/latest/

.. |workon| replace:: ``workon``
.. _workon: https://virtualenvwrapper.readthedocs.io/en/latest/command_ref.html?highlight=workon#workon

To install system-wide, run as superuser::

    $ pip3 install easy-as-pypi-appdirs

To install user-local, simply run::

    $ pip3 install -U easy-as-pypi-appdirs

To install within a |virtualenv|_, try::

    $ mkvirtualenv easy-as-pypi-appdirs
    (easy-as-pypi-appdirs) $ pip install release-ghub-pypi

To develop on the project, link to the source files instead::

    (easy-as-pypi-appdirs) $ deactivate
    $ rmvirtualenv easy-as-pypi-appdirs
    $ git clone git@github.com:doblabs/easy-as-pypi-appdirs.git
    $ cd easy-as-pypi-appdirs
    $ mkvirtualenv -a $(pwd) --python=/usr/bin/python3.8 easy-as-pypi-appdirs
    (easy-as-pypi-appdirs) $ make develop

After creating the virtual environment,
to start developing from a fresh terminal, run |workon|_::

    $ workon easy-as-pypi-appdirs
    (easy-as-pypi-appdirs) $ ...

