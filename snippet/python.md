
# PIP Configuration

pip.conf/pip.ini should be located in the following place:
- On Unix: `$HOME/.config/pip/pip.conf`
- On Windows: `%APPDATA%\pip\pip.ini`
- On macOS : `$HOME/Library/Application Support/pip/pip.conf`

Inside a virtualenv:
- On Unix and macOS: $VIRTUAL_ENV/pip.conf
- On Windows: %VIRTUAL_ENV%\pip.ini
	
Example to access a private pip repository:
```ini
[global]
timeout = 60
index-url = https://user:pass@download.artifactory.intra/python/pypi/simple
```

Check the pip configuration
```
pip config list
```

Create a virtualenv with Python 3 venv:
```
python -m venv <env-name>
```

# Language

## Positional and keyword arguments

keyword argument: an argument preceded by an identifier (e.g. name=) in a function call or passed as a value in a dictionary preceded by \*\*
```python
complex(real=3, imag=5)
complex(**{'real': 3, 'imag': 5})
```

positional argument: an argument that is not a keyword argument. Positional arguments can appear at the beginning of an argument list and/or be passed as elements of an iterable preceded by \*.
```python
complex(3, 5)
complex(*(3, 5))
```

Default argument in Function definition:
- Any number of arguments in a function can have a default value. But once we have a default argument, all the arguments to its right must also have default values.
Otherwise: `SyntaxError: non-default argument follows default argument`

- Non-default arguments must be provided in function call (with positional or keyword arguments)
Otherwise: `TypeError: simpleFunction() missing 1 required positional argument: 'first'`

- Keyword arguments in Function call:
We can mix positional arguments with keyword arguments during a function call. Keyword arguments must follow positional arguments.
Otherwise: `SyntaxError: non-keyword arg after keyword arg`


Related PEP:
- PEP-3102: Keyword-Only Arguments https://www.python.org/dev/peps/pep-3102/
- PEP-570: Positional-only parameters in Python 3.8 https://www.python.org/dev/peps/pep-0570/

Positional-only parameters would be placed before a / (forward-slash). The / is used to logically separate the positional-only parameters from the rest of the parameters. If there is no / in the function definition, there are no positional-only parameters.

To mark parameters as keyword-only, indicating the parameters must be passed by keyword argument, place an * in the arguments list just before the first keyword-only parameter.

```python
def combined_example(pos_only, /, standard, *, kwd_only):
    print(pos_only, standard, kwd_only)
```


## Class variable & instance variable

```python
class Product:
    a_class_variable = 0
    another_class_variable = "error message"
    lock = Lock()

    def __init__(self, name, price):
        self.name = name  # an instance variable
        self.price = price
```


## Static methods & class method
```python

class MyClass:
    
    def method(self): # regular method: can access to instance and class variables
        return 'instance method called', self
    
    @classmethod # can access to class variables, but not to instance variables
    def classmethod(cls):
        return 'class method called', cls
    
    @staticmethod # static method: cannot access instance nor class variables
    def add(x: int, y: int):
        return x + y


    def call_method():
        myobject = MyClass()
        myobject.method()
        # or 
        MyClass.method(myobject)


```
```python
class Product:

    def __init__(self, name, price):
        self.name = name  # an instance variable
        self.price = price

    def __repr__(self):
        return (f'Product({self.name}: {self.price}€)')

    @classmethod
    def createProduct(cls, name, price):  # Generic Factory method
        return cls(name, price)

    @classmethod
    def createBaguette(cls):  # Factory method
        return cls('Baguette', 1)


def main():
    baguette = Product.createBaguette()
    print(baguette)
```

## Strings Format

### %-formatting

```python
product = 'keyboard'
price = 100
"The price of %s is %i." % (product, price)
```

### str.format() 
Since Python 2.6

```python
"The price of {} is {}.".format(product, price)
```

### f-strings
Since Python 3.6

```python
f'The price of {product} is {price}.'
```

By default, f-strings will use __str__(), but you can make sure they use __repr__() if you include the conversion flag !r:
```python
f'The price of {product!r} is {price}.'
```


## Call the super() method

```python
super().__init__(params, ...)
super(SubClass, self).__init__(params, ...)
```
In Python 3, the super(SubClass, self) call is equivalent to the parameterless super() call. 

Call the base class
```python
super().__init()
```

# Examples, tips
## Format json 
```bash
curl -s http://www.meteo-paris.com/ajax/realtime | python -c 'import sys, json; print json.load(sys.stdin)["station"]["temp_webcam"]'
```

Start a HTTP Server serving filesystem: 
- python 2:
```bash
$ python -m SimpleHTTPServer 8000
```
https://docs.python.org/2/library/simplehttpserver.html

- python 3: 
```bash
$ python -m http.server --directory /tmp/
```
https://docs.python.org/3/library/http.server.html

## Write to a binary file
```python
file = open("file.bin","wb")
file.write(byte)
```


## System calls in Python!

Allows to perform file control and I/O control on file descriptors
```python
fcntl.ioctl(
  s.fileno(),
  0x8912,  # SIOCGIFCONF
  struct.pack('iL', bytes, names.buffer_info()[0])
  )
```
  

## Data types

https://docs.python.org/3/library/datatypes.html



## Sort

Sort a list in place:
```python
l = [3, 2, 3, 1, 2]
l.sort()
print(l) # [1, 2, 2, 3, 3]
```

Create another list without modifying the given list:
```python
l = [3, 2, 3, 1, 2]
liste = sorted(l)
print(liste) # [1, 2, 2, 3, 3]
print(l)     # [3, 2, 3, 1, 2]
```


Create a sorted list from values in a set:
```python
s = {3, 2, 3, 1, 2}
print(s) # {1, 2, 3}
liste = sorted(s) # [1, 2, 3]
```

Sort a dict by key in Python 3
```python
dico = {"lundi": 33, "mardi": 34, "mercredi": 31, "jeudi": 29, "vendredi": 26, "samedi": 28, "dimanche": 26}
listKeys = sorted(dico.keys())
print(listKeys)  # print only sorted keys
listKeyValues = sorted(dico.items(), key=lambda kv: kv[0], reverse=True)
print(listKeyValues)  # print keys in reverse order with their values
```


Sort a dict by value in Python 3
```python
dico = {"lundi": 33, "mardi": 34, "mercredi": 31, "jeudi": 29, "vendredi": 26, "samedi": 28, "dimanche": 26}
listKeyValues = sorted(dico.items(), key=lambda kv: kv[1], reverse=True)
print(listKeyValues)  # [('mardi', 34), ('lundi', 33), ('mercredi', 31), ('jeudi', 29), ('samedi', 28), ('vendredi', 26), ('dimanche', 26)]
```


# Dict

A mapping object maps hashable values to arbitrary objects. Mappings are mutable objects. Empty dict can be created with {}.
The objects returned by dict.keys(), dict.values() and dict.items() are view objects. They provide a dynamic view on the dictionary’s entries, which means that when the dictionary changes, the view reflects these changes.

## defaultdict

```python
from collections import defaultdict
dico = defaultdict(lambda: 0)
for c in "Hello world":
    dico[c.lower()] += 1

print(dico)
# defaultdict(<function <lambda> at 0x0000019DBF02C1E0>, {'h': 1, 'e': 1, 'l': 3, 'o': 2, ' ': 1, 'w': 1, 'r': 1, 'd': 1})
```

```python
from collections import defaultdict
dico_position_character = defaultdict(lambda: list()) # argument must a callable without argument: don't forget parentheses in list()!
for i, c in enumerate("Hello world"):
    dico_position_character[c.lower()].append(i)

print(dico_position_character)
# defaultdict(<function <lambda> at 0x0000019DBF02C1E0>, {'h': [0], 'e': [1], 'l': [2, 3, 9], 'o': [4, 7], ' ': [5], 'w': [6], 'r': [8], 'd': [10]})
```

Equivalent to a simple dict using the `setdefault` method:
```python
dico_position_character = {}
for i, c in enumerate("Hello world"):
    l = dico_position_character.setdefault(c.lower(), [])
    l.append(i)

print(dico_position_character) # {'h': [0], 'e': [1], 'l': [2, 3, 9], 'o': [4, 7], ' ': [5], 'w': [6], 'r': [8], 'd': [10]}
```

## OrderedDict
Ordered dictionaries are just like regular dictionaries but have some extra capabilities relating to ordering operations. They have become less important now that the built-in dict class gained the ability to remember **insertion order** (this new behavior became guaranteed in Python 3.7).


## Collections maintaining natural order
Python standard library has not Java equivalent of TreeMap, TreeSet; but external libraries offer these lacking features, for example: http://www.grantjenks.com/docs/sortedcontainers/

```bash
$ pip install sortedcontainers
```

```python
>>> import sortedcontainers
>>> help(sortedcontainers)
>>> from sortedcontainers import SortedDict
>>> help(SortedDict)
>>> help(SortedDict.popitem)
```
```python
>>> from sortedcontainers import SortedList
>>> sl = SortedList(['e', 'a', 'c', 'd', 'b'])
>>> sl
SortedList(['a', 'b', 'c', 'd', 'e'])
>>> sl *= 10_000_000
>>> sl.count('c')
10000000
>>> sl[-3:]
['e', 'e', 'e']
>>> from sortedcontainers import SortedDict
>>> sd = SortedDict({'c': 3, 'a': 1, 'b': 2})
>>> sd
SortedDict({'a': 1, 'b': 2, 'c': 3})
>>> sd.popitem(index=-1)
('c', 3)
>>> from sortedcontainers import SortedSet
>>> ss = SortedSet('abracadabra')
>>> ss
SortedSet(['a', 'b', 'c', 'd', 'r'])
>>> ss.bisect_left('c')
2
```

## Time type

https://docs.python.org/3/library/datetime.html

```python
>>> from datetime import datetime, date, time, timezone

>>> datetime.now()
datetime.datetime(2020, 9, 14, 11, 42, 22, 225278)  # Contrary to Java, January month is coded 1

>>> d = date(2020, 3, 17)
>>> d
datetime.date(2020, 3, 17)
>>> t = time(12, 30)
>>> dt = datetime.combine(d, t)
>>> dt
datetime.datetime(2020, 3, 17, 12, 30)
>>> datetime.timetuple()
time.struct_time(tm_year=2020, tm_mon=3, tm_mday=17, tm_hour=12, tm_min=30, tm_sec=0, tm_wday=1, tm_yday=77, tm_isdst=-1)
>>> dt.strftime("%A, %d. %B %Y %I:%M%p")
'Tuesday, 17. March 2020 12:30PM'
>>> dt.strftime("%d/%m/%Y %H:%M:%S")
'17/03/2020 12:30:00'
# https://docs.python.org/3/library/datetime.html#strftime-and-strptime-behavior

>>> datetime.fromisoformat('2020-09-14 11:56:07.123+02:00')
datetime.datetime(2020, 9, 14, 11, 56, 7, 123000, tzinfo=datetime.timezone(datetime.timedelta(seconds=7200)))
```


A timedelta object represents a duration, the difference between two dates or times.

```python
>>> from datetime import timedelta

# lunaison: 29 jours 12 heures 44 minutes et 2,9 secondes
>>> lunaison = timedelta(days=29, hours=12, minutes=44, seconds=2.9)
>>> lunaison
datetime.timedelta(days=29, seconds=45842, microseconds=900000)
>>> full_moon = datetime(2020, 9, 2, 05, 22)
>>> full_moon + lunaison
datetime.datetime(2020, 10, 1, 18, 6, 2, 900000)
```


## Columns Formatting
```python
dico = {"lundi": 33, "mardi": 34, "mercredi": 31, "jeudi": 29, "vendredi": 26, "samedi": 28, "dimanche": 26}
liste_tuples = sorted(dico.items(), key=lambda kv: kv[1])
for kv in liste_tuples:
    print("- {: <10} {: >3}".format(kv[0], kv[1]))  # with string.format()
    print(f"- {kv[0]: <10} {kv[1]: >3}")            # with f-strings
```
prints:
```
- vendredi    26
- dimanche    26
- samedi      28
- jeudi       29
- mercredi    31
- lundi       33
- mardi       34
```



## Packaging

Create a wheel
```bash
$ pip install wheel
$ python setup.py bdist_wheel
```

Compute oneself the RECORD file lines in wheel archive:
```bash
$ stat -c%s mypackage/__init__.p
$ sha256sum mypackage/__init__.py | cut -f1 | xxd -r -p | base64 | tr +/ -_ | cut -c -43
```