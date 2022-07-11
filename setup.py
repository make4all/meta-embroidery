from setuptools import find_packages, setup
setup(
    name='metamaterial_generator',
    packages=find_packages(include=['metamaterial_generator']),
    version='0.1.0',
    description='Metamaterial Generator',
    author='Jennifer Mankoff and Arun Mankoff-Dey',
    install_requires=['svgpathtools'],
    setup_requires=['pytest-runner'],
    tests_require=['pytest==4.4.1'],
    test_suite='demos',
    license='MIT',
)
