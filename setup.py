from setuptools import setup
import sys
import os

setup(
    name = 'hello',
    version = '0.1.0',
    description = 'Python test package',
    license='GPL v3',
    author = 'my name',
    packages = ['hello'],
    package_data={'hello': ['description.txt']
                 },
    install_requires=[
        'future'
    ],
    scripts = [
        'bin/hello',
        '/bin/vers'
    ],
    classifiers = [
            'Operating System :: OS Independent',
            'Programming Language :: Python :: 2.7',
            'Programming Language :: Python :: 3.6',
            'Operating System :: MacOS :: MacOS X',
            'Operating System :: Microsoft :: Windows',
            'Operating System :: POSIX',
            'License :: OSI Approved :: GNU General Public License v3 (GPLv3)'],
)