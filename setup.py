from setuptools import setup, find_packages

version = '0.7.2'

long_description = """
%s

Changelog
=========

%s
""" % (open('README.rst').read(),
       open('docs/CHANGES.txt').read())

setup(name='opencore-fassembler_boot',
      version=version,
      description="Creates a setup for new OpenCore site deployments that use Fassembler",
      long_description=long_description,
      # Get strings from https://pypi.org/pypi?:action=list_classifiers
      classifiers=[
        "Development Status :: 3 - Alpha",
        "Environment :: Console",
        "Environment :: Plugins",
        "Intended Audience :: Developers",
        "Intended Audience :: System Administrators",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        "Natural Language :: English",
        "Operating System :: Unix",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2.4",
        "Programming Language :: Python :: 2 :: Only",
        "Topic :: Desktop Environment :: File Managers",
        "Topic :: Software Development :: Assemblers",
        "Topic :: System :: Systems Administration",
      ],
      keywords='fassembler bootstrap console scripts setup opencore site deployments socialplanning',
      author='opencore developers',
      author_email='opencore-dev@lists.coactivate.org',
      url='http://www.coactivate.org/projects/opencore',
      license='GPLv3',
      packages=find_packages(exclude=['ez_setup', 'examples', 'tests']),
      include_package_data=True,
      zip_safe=False,
      install_requires=[
        "Tempita",
        "setuptools",
        ],
      entry_points="""
      [console_scripts]
      new-opencore-site = fassembler_boot.newsite:main
      new-opencore-site-config = fassembler_boot.newsite:config
      rebuild-opencore-site = fassembler_boot.newbuild:main
      """,
      )
      
