# QP
This repository hosts a MATLAB class "QP" that simplifies the process defining, solving, plotting and styling your Quadratic Program (with two decision variables).
The repo is divided into Tutorials, Exercises and Examples, aimed at teaching beginners how to plot QPs in a simpel manner, teaching you how to use the QP-class, and give exercise in formulating QPs.

Let me know (create an issue, or send me a message) if you find any bugs, of if there is some functionality you would want me to add.
Though it seems to work very well, I have not tested this extensively, and there are always some bugs/unintentional stuff that sneaks in.

The QP-class is intended to be easy to use and low effort to 'install'. Therefore, it is completely stand-alone, and does not require any other classes, toolboxes or functions outside of the **standard MATLAB toolbox** and the **Optimization Toolbox**. Simply add the "QP.m" file to the MATLAB path, or the working directory/folder, and it should work!

### Classes:

- **QP.m**, This is a class called "QP". Have this in the folder you are working in (or somewhere else on the MATLAB path), to make it available to your scripts. This class containts many functions that automates the plotting of a QP for you, and makes it super easy to test and tweak different parameters in your QP. The class has implemented a workaround, to retrieve the iteration values of the quadprog algorithm you use, which is not possible via _quadprog()_ as of R2022a. Try _myQP.plotIterations()_.

  - Requirements: [Optimization Toolbox](https://se.mathworks.com/help/optim/index.html?s_tid=CRUX_lftnav)


### Tutorials:

- **Basic_QP_plots.m**, This is a script that goes through various steps that can be used to plot a QP. Read through the lines as you run the various secions (ctrl + enter) in sequence, and see what happens.

- **UsingQPclass.m**, This is a script that shows how to use the QP class. Run each section in sequence (ctrl + enter)/(ctrl + shift + enter) as you read the comments, and learn how to use the QP class, such that you may use it to easily plot your QPs!


### Examples

Here are the outputs of the examples, so you can see some of what the QP class can do:

- Example 1:

![Example_1_Optimal_Party](https://user-images.githubusercontent.com/55924651/219601053-89facfa8-b9e8-47d8-a406-95d8815be31d.png)

- Example 2:

![Example_2_Optimal_Study_Plan](https://user-images.githubusercontent.com/55924651/219601061-c82b33dd-5ec0-43c9-b9a3-c8689fa9698b.png)


