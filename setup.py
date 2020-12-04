import os
from setuptools import setup

here = os.path.abspath(os.path.dirname(__file__))
# Note we should only include packages required for execution and not development
# enum-compat is used to install enum34 for python3.4 or below, otherwise it is a no-op
with open(os.path.join(here, 'requirements.txt'), 'r') as reqs:
    requirements = list()
    for line in reqs.readlines():
        requirements.append(line)

setup(
    name = 'app',
    version = '0.1.0',
    description = 'Python test package',
    license='MIT',
    author = 'Christian',
    packages = ['app'],
    package_data={
        'app': ['description.txt']
    },
    install_requires=requirements,
    scripts = [
        'bin/app',
    ],
    classifiers = [
        'Programming Language :: Python :: 3.8',
        'License :: OSI Approved :: MIT License'
    ],
)
