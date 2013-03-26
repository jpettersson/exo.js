exo.js
======

Introduction
------------

Exo handles the complex and tangled state management of heavily animated and real time JavaScript GUIs. 

* Buttons
* Menus
* Sections
* Lists

Exo components can be used standalone but are also designed to integrate with controllers in MVC frameworks, such as [Spine.js](http://spinejs.com/). 

You can use Exo with any animation library (or use CSS transitions). Most of the examples in this documentation use the excellent [TweenLite](http://www.greensock.com/gsap-js/) library.

Core principles
---------------

Exo is based on the idea that it's possible to reduce complex GUI logic into arrangements of a single fundamental building block.

In Exo this building block is called a 'Node' and is a simple implementation of a [Finite state-machine](http://en.wikipedia.org/wiki/Finite-state_machine). 

A Node has two states: 
'activated', 'deactivated' 

And two transitions: 
'deactivate', 'activate'.

```
       --- activate -->>
     /                   \
deactivated          activated
     \                   /
      <<- deactivate ---
```

A Node is not allowed to transition to and from the same state. Further, a node is not allowed to initiate a transition while another transition is still running. While a Node is executing a transition it is considered to be "busy".

As the examples will demonstrate, we can take advantage of these constraints by using the successful initiation of a state transition to control a corresponding animation. After the animation is finished we invoke a callback on the node to finish the state transition, unlocking the state machine.

The Exo.Node class
------------------

The Node is defined as a CoffeeScript class and can be directly instantiated or inherited from.

A node has 6 public instance methods that are related to it's internal state control: 

```
METHOD                Description

activate              Attempt to activate the Node

doActivate            Called by the state machine if the transition is possible.
                      Example: Override to initiate a TweenLite animation.

onActivated           Should be called when the transition is done.
                      Example: Called as the TweenLite onComplete callback.

deactivate            Attempt to deactivate the Node

doDeactivate          Called by the state machine if the transition is possible.
                      Example: Called as the TweenLite onComplete callback.

onDeactivated         Should be called when the transition is done.
                      Example: Called as the TweenLite onComplete callback.
```

By default the Node functions 'doActivate' and 'doDeactivated' are defined to immediately call their respective callbacks, enabling the state-machine to transition between states instantaneously.

What is more interesting is to override the default behavior and wait for a blocking process to finish, for instance a time delay: 

```CoffeeScript

###
Example: Using a timeout to delay the transition.

The transition begins when 'doActivate' is called and ends when 
'onActivated' is called 500ms later, executed from the timeout.
###

node = new Exo.Node

node.doActivate = -> 
  setTimeout =>
    @onActivated()
  , .5

node.onActivated = ->
  super
  console.log 'Activated!'

node.activate()

```

Of course, it would make more sense to do something useful when transitioning, for instance running TweenLite animation:

```CoffeeScript

###
Example: Playing a TweenLite animation when the 'activate' transition begins.
###

node = new Exo.Node

node.doActivate = ->
  TweenLite.from $('body'), ,5
    css:
      alpha: 0
    onComplete: @onActivated

node.activate()

```

As outlined above, the internal state-machine will not allow multiple transitions at the same time and keeps strict control over which transition can be initiated at a given point in time. We can for instance leverage this behavior to ensure that a button-initiated animation is only started once, no matter how many times the user clicks the button.

Control Hierarchies
-------------------

Nodes can be arranged into tree-like hierarchies where state transitions depend on both 

* Control hierarchies
  - Explain Parent, Child, Sibling

Terminology
-----------

The terminology used in Exo is borrowed from [Graph Theory](http://en.wikipedia.org/wiki/Tree_(graph_theory)). Actually, a hierarchy of Exo nodes can also be visualized as a directed acyclic graph.

Examples
--------

