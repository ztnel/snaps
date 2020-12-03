from setuptools import setup
import sys
import os

setup(
    name = 'hello',
    version = '0.1.0',
    description = 'Python test package',
    license='MIT',
    author = 'Christian',
    packages = ['hello'],
    package_data={
        'hello': ['description.txt']
    },
    install_requires=[
        'future'
    ],
    scripts = [
        'bin/hello',
        'bin/vers'
    ],
    classifiers = [
        'Programming Language :: Python :: 3.8',
        'License :: OSI Approved :: MIT License'
    ],
)
