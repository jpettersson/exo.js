exo.js
======

Introduction
------------

Exo handles the complex and tangled state management of heavily animated and real time JavaScript GUIs. 

* Buttons
* Menus
* Sections
* Lists

Exo components can be used standalone but are also designed to integrate with controllers in MVC frameworks, such as Spine.js. 

You can use Exo with any animation library (or use CSS transitions). Most of the examples in this documentation use the excellent [TweenLite](http://www.greensock.com/gsap-js/) library.

Core principles
---------------

Exo is based on the idea that it's possible to reduce complex GUI logic into arrangements of a fundamental building block.

In Exo this building block is called a 'Node' and is a simple implementation of a [Finite state-machine](http://en.wikipedia.org/wiki/Finite-state_machine). 

A Node has two states: 
'activated', 'deactivated' 

And two transitions: 
'deactivate', 'activate'.

A Node is not allowed to transition to and from the same state. Further, a node is not allowed to initiate a transition while another transition is still running. We can take advantage of these constraints by using the successful initiation of a state transition to control a corresponding animation.

```CoffeeScript

node = new Exo.Node

node.doActivate = -> @onActivated()
node.doDectivate = -> @onDeactivated()

node.activate()
node.deactivate()

```



State Transition Table
```
                  activate    deactivate
activated         false       true
deactivated       true        false
```

Graph representation
```
       --- activate -->>
     /                   \
deactivated          activated
     \                   /
      <<- deactivate ---
```



* Transitional logic
  - activate
  - doActivate
  - onActivated
  - deactivate
  - doDeactivate
  - onDeactivated

Control Hierarchies
-------------------

* Control hierarchies
  - Explain Parent, Child, Sibling

```
            parent                                   child                 

       --- activate -->>                --->>   --- activate -->>          
     /                   \            /       /                   \        
deactivated         [activated] -----    deactivated          activated    
     \                   /                    \                   /        
      <<- deactivate ---                       <<- deactivate ---          
```


Terminology
-----------

The terminology used in Exo is borrowed from [Graph Theory](http://en.wikipedia.org/wiki/Tree_(graph_theory)). Actually, a hierarchy of Exo nodes can also be visualized as a directed acyclic graph.

Examples
--------

