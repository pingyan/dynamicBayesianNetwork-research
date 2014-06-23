/* -------------------------------------------------------------------------- */
/*                                                                            */
/*                      ASSOCIATION RULE DATA MINING                          */
/*                                                                            */
/*                              Frans Coenen                                  */
/*                                                                            */
/*                          Monday 15 June 2003                               */
/*                                                                            */
/*                    Department of Computer Science                          */
/*                     The University of Liverpool                            */
/*                                                                            */ 
/* -------------------------------------------------------------------------- */

import java.io.*;
import java.util.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

// Other packages

public class AprioriTgui extends JFrame implements ActionListener{
    
    /* ------ FIELDS ------ */
    
    // GUI features
    private BufferedReader fileInput;
    private JTextArea textArea;
    private JButton openButton, minSupport, runButton;
    
    /** Ttree node structure. <P> Arrays of these structures are used to store 
    nodes at the same level in any sub-branch of the T-tree.  */
    
    protected class TtreeNode {
    	/** The support associate wuth the itemset represented by the node. */
        protected int support = 0;
	/** A reference variable to the child (if any) of the node. */
	protected TtreeNode[] childRef = null;
	
	/** Default constructor */
	
	protected TtreeNode() {
	    }
	
	/** One argument constructor. 
	@param sup the support value to be included in the structure. */
	
	private TtreeNode(int sup) {
	    support = sup;
	    }
	}
    
    // Data structures    
    /** The reference to start of t-tree. */
    private TtreeNode[] startTtreeRef; 
    /** 2-D aray to hold input data from data file */
    private short[][] dataArray = null;
    
    // Constants    
    /** Minimum support value */
    private static final double MIN_SUPPORT = 0.0;
    /** Maximum support value */
    private static final double MAX_SUPPORT = 100.0;
    
    // Flags
    /** Input format PK flag */
    private boolean inputFormatOkFlag = true;
    /** Flag to indicate whether system has data or not. */
    private boolean haveDataFlag = false;
    /** Flag to indicate whether system has support value or not. */
    private boolean hasSupportFlag = false;
    /** The next level indicator flag: set to <TT>true</TT> if new level generated 
    and by default. */
    private boolean nextLevelExists = true ;  
    
    // Other fields
    /** Data file name. */	
    private File fileName;
    /** Number of rows. */
    private int numRows    = 0;
    /** Number of Cols. */
    private int numCols = 0;
    /** Support. */
    private double support = 20.0;
    /** Minimum support in terms of rows. */
    private double minSupportRows = 1.0;
    
    public AprioriTgui(String s) {
        super(s);
        
	// Content pane
        Container container = getContentPane(); 
        container.setBackground(Color.pink);
        container.setLayout(new BorderLayout(5,5)); // 5 pixel gaps
	
	// Run button
	runButton = new JButton("Run");
        runButton.addActionListener(this);
	runButton.setEnabled(false);
	
        // Open button
        openButton = new JButton("Open File");
        openButton.addActionListener(this);
	
	// Input Support
	minSupport = new JButton("Add Min. Sup.");
        minSupport.addActionListener(this);
	
	// Button Panel
	JPanel buttonPanel = new JPanel();
	buttonPanel.setLayout(new GridLayout(1,3));
	buttonPanel.add(openButton);
	buttonPanel.add(minSupport);
	buttonPanel.add(runButton);
	container.add(buttonPanel,BorderLayout.NORTH); 
	
	// Text area	
	textArea = new JTextArea(40, 15);
	textArea.setEditable(false);
        container.add(new JScrollPane(textArea),BorderLayout.CENTER);
        
	// Credits Panel
	JPanel creditsPanel = new JPanel();
	creditsPanel.setBackground(Color.pink);
	creditsPanel.setLayout(new GridLayout(4,1));
	Label creditLabel1 = new Label("LUCS-KDD (Liverpool University Computer " +
				"Science - Knowledge Discovery");
	Label creditLabel2 = new Label("in Data) group Apriori-T " +
				"demonstrator.");
	Label creditLabel3 = new Label(" ");
	Label creditLabel4 = new Label("Created by Frans Coenen (17 June " +
				"2003)");			
	creditsPanel.add(creditLabel1);
	creditsPanel.add(creditLabel2);
	creditsPanel.add(creditLabel3);
	creditsPanel.add(creditLabel4);
	container.add(creditsPanel,BorderLayout.SOUTH);
	}
    
    /* ACTION PERFORMED */
    
    public void actionPerformed(ActionEvent event) {
        if (event.getActionCommand().equals("Open File")) getFileName();
	if (event.getActionCommand().equals("Read File")) readFile();
        if (event.getActionCommand().equals("Add Min. Sup.")) addSupport();
	if (event.getActionCommand().equals("Run")) aprioriT();
	}
	
    /* ---------------------------------------------------------------- */
    /*                                                                  */
    /*                            APRIORI-T                             */
    /*                                                                  */
    /* ---------------------------------------------------------------- */
    
    private void aprioriT() {
 	textArea.append("Apriori-T (Minimum support threshold = " + support +
		     "%)\n-----------------------------------------\n" +
		"Generating K=1 large itemsets\n");
        
	// Determin mimimum support in terms of rows
	minSupportRows = numRows*support/100.0;
	
	// Create Top level of T-tree (First pass of dataset)	
	createTtreeTopLevel();
	
	// Generate level 2
	generateLevel2();
	
	// Further passes of the dataset		
	createTtreeLevelN();
	
	textArea.append("\n");
	outputFrequentSets();
	}

    /* CREATE T-TREE TOP LEVEL */
    
    /** Generates level 1 (top) of the T-tree. */
    		
    protected void createTtreeTopLevel() {
    
	// Dimension and initialise top level of T-tree
	
	startTtreeRef = new TtreeNode[numCols+1];
	for (int index=1;index<=numCols;index++) 
	    			startTtreeRef[index] = new TtreeNode();
	    
        // Add support for each 1 itemset
        
	createTtreeTopLevel2();
	
	// Prune top level, setting any unsupport 1 itemsets to null 

	pruneLevelN(startTtreeRef,1); 
	}
	
    /** Adds supports to level 1 (top) of the T-tree. */
    	
    protected void createTtreeTopLevel2() {
	    
        // Loop through data set record by record and add support for each
	// 1 itemset
        
	for (int index1=0;index1<dataArray.length;index1++) {
	    // Non null record (if initial data set has been reordered and
	    // pruned some records may be empty!
	    if (dataArray[index1] != null) {
    	        for (int index2=0;index2<dataArray[index1].length;index2++) {
		    startTtreeRef[dataArray[index1][index2]].support++; 
		    }
		}
	    }
	}	
	
    /* CREATE T-TREE LEVEL N */
    
    /** Commences the process of determining the remaining levels in the T-tree 
    (other than the top level), level by level in an "Apriori" manner. <P>
    Follows an add support, prune, generate loop until there are no more levels 
    to generate. */
    
    protected void createTtreeLevelN() {
        int nextLevel=2;
   	
	// Loop while a further level exists
	
	while (nextLevelExists) { 
	    textArea.append("Generating K=" + nextLevel + " large itemsets\n");
	    // Add support   
	    addSupportToTtreeLevelN(nextLevel);
	    // Prune unsupported candidate sets
	    pruneLevelN(startTtreeRef,nextLevel);
	    // Attempt to generate next level 
	    nextLevelExists=false;
	    generateLevelN(startTtreeRef,1,nextLevel,null); 
	    nextLevel++;
	    }   
	}
 			
    /* ADD SUPPORT VALUES TO T-TREE LEVEL N */
    
    /** Commences process of adding support to a given level in the T-tree 
    (other than the top level). 
    @param level the current level number (top leve = 1). */
     	
    protected void addSupportToTtreeLevelN(int level) {
	// Loop through data set record by record
        for (int index=0;index<dataArray.length;index++) {
	    // Non null record (if initial data set has been reordered and
	    // pruned some records may be empty
	    if (dataArray[index] != null) {
	        addSupportToTtreeFindLevel(startTtreeRef,level,
				dataArray[index].length,dataArray[index]);
	        }
	    }
	} 
	
    /* ADD SUPPORT TO T-TREE FIND LEVEL */
    
    /** Adds support to a given level in the T-tree (other than the top level).
    <P> Operates in a recursive manner to first find the appropriate level in 
    the T-tree before processing the required level (when found). 
    @param linkRef the reference to the current sub-branch of T-tree (start at 
    top of tree)
    @param level the level marker, set to the required level at the start and 
    then decremented by 1 on each recursion. 
    @param endIndex the length of current level in a sub-branch of the T-tree.
    @param itemSet the current itemset under consideration. */
    
    private void addSupportToTtreeFindLevel(TtreeNode[] linkRef, int level, 
    			int endIndex, short[] itemSet) {
	
	// At right leve;
	
	if (level == 1) {
	    // Step through itemSet
	    for (int index1=0;index1 < endIndex;index1++) {
		// If valid node update, i.e. a non null node
		if (linkRef[itemSet[index1]] != null) {
		    linkRef[itemSet[index1]].support++; 
		    }
		}
	    }
	
	// At wrong level    
	
	else {
	    // Step through itemSet
	    for (int index=0;index<endIndex;index++) {		
		// If child branch step down branch
		if (linkRef[itemSet[index]] != null) {
		    if (linkRef[itemSet[index]].childRef != null) 
		    	 addSupportToTtreeFindLevel(linkRef[itemSet[index]].childRef,
						level-1,index,itemSet);
		    }
		}
	    }	
	}
	
    /*---------------------------------------------------------------------- */
    /*                                                                       */
    /*                                 PRUNING                               */
    /*                                                                       */
    /*---------------------------------------------------------------------- */ 
    
    /* PRUNE LEVEL N */
    
    /** Prunes the given level in the T-tree. <P> Operates in a recursive 
    manner to first find the appropriate level in the T-tree before processing 
    the required level (when found). Pruning carried out according to value of
    <TT>minSupport</TT> field.
    @param linkRef The reference to the current sub-branch of T-tree (start at 
    top of tree)
    @param level the level marker, set to the required level at the start and 
    then decremented by 1 on each recursion. */
    
    protected void pruneLevelN(TtreeNode [] linkRef, int level) {
        int size = linkRef.length;
	
	// At right leve;
	
	if (level == 1) {
	    // Step through level and set to null where below min support
	    for (int index1=1;index1 < size;index1++) {
	        if (linkRef[index1] != null) {
	            if (linkRef[index1].support < minSupportRows) 
		    		linkRef[index1] = null;
	            }
		}
	    }
	    
	// Wrong level
	 
	else {
	    // Step through row
	    for (int index1=1;index1 < size;index1++) {
	        if (linkRef[index1] != null) {		
		    // If child branch step down branch
		    if (linkRef[index1].childRef != null) 
				pruneLevelN(linkRef[index1].childRef,level-1);
		    }
		}
	    }	
	}
				
    /*---------------------------------------------------------------------- */
    /*                                                                       */
    /*                            LEVEL GENERATION                           */
    /*                                                                       */
    /*---------------------------------------------------------------------- */ 
    
    /* GENERATE LEVEL 2 */
    
    /** Generates level 2 of the T-tree. <P> The general 
    <TT>generateLevelN</TT> method assumes we have to first find the right 
    level in the T-tree, that is not necessary in this case of level 2. */
    
    protected void generateLevel2() {
	
	// Set next level flag
	
	nextLevelExists=false;
	
	// loop through top level
	
	for (int index=2;index<startTtreeRef.length;index++) {
	    // If supported T-tree node (i.e. it exists)
	    if (startTtreeRef[index] != null) generateNextLevel(startTtreeRef,
	    				index,realloc2(null,(short) index));		
	    }
	}
	
    /* GENERATE LEVEL N */
    
    /** Commences process of generating remaining levels in the T-tree (other 
    than top and 2nd levels). <P> Proceeds in a recursive manner level by level
    untill the required level is reached. Example, if we have a T-tree of the form:
    
    <PRE>
    (A) ----- (B) ----- (C)
               |         |
	       |         |
	      (A)       (A) ----- (B)
    </PRE><P>	                           
    Where all nodes are supported and we wish to add the third level we would
    walk the tree and attempt to add new nodes to every level 2 node found.
    Having found the correct level we step through starting from B (we cannot
    add a node to A), so in this case there is only one node from which a level
    3 node may be attached. 
    @param linkRef the reference to the current sub-branch of T-tree (start at 
    top of tree).
    @param level the level marker, set to 1 at the start of the recursion and 
    incremented by 1 on each repetition. 
    @param requiredLevel the required level.
    @param itemSet the current itemset under consideration. */
    
    protected void generateLevelN(TtreeNode[] linkRef, int level, 
    					int requiredLevel, short[] itemSet) {
	int index1;
	int localSize = linkRef.length;
	
	// Correct level
	
	if (level == requiredLevel) {
	    for (index1=2;index1<localSize;index1++) {
	        // If supported T-tree node
	    	if (linkRef[index1] != null) generateNextLevel(linkRef,index1,
					realloc2(itemSet,(short) index1));		
	        }
	    }
	
	// Wrong level
	
	else {
	    for (index1=2;index1<localSize;index1++) {
	        // If supported T-tree node
	        if (linkRef[index1] != null) {
		    generateLevelN(linkRef[index1].childRef,level+1,
		    		requiredLevel,realloc2(itemSet,(short) index1));
		    }	
		}
	    }
	}

    /* GENERATE NEXT LEVEL */
    
    /** Generates a new level in the T-tree from a given "parent" node. <P> 
    Example 1, given the following:
    
    <PRE>
    (A) ----- (B) ----- (C)
               |         |
	       |         |
	      (A)       (A) ----- (B) 
    </PRE><P>	      
    where we wish to add a level 3 node to node (B), i.e. the node {A}, we 
    would proceed as follows:
    <OL>
    <LI> Generate a new level in the T-tree attached to node (B) of length 
    one less than the numeric equivalent of B i.e. 2-1=1.
    <LI> Loop through parent level from (A) to node immediately before (B). 
    <LI> For each supported parent node create an itemset label by combing the
    index of the parent node (e.g. A) with the complete itemset label for B --- 
    {C,B} (note reverse order), thus for parent node (B) we would get a new
    level in the T-tree with one node in it --- {C,B,A} represented as A.
    <LI> For this node to be a candidate large item set its size-1 subsets must 
    be supported, there are three of these in this example {C,A}, {C,B} and
    {B,A}. We know that the first two are supported because they are in the
    current branch, but {B,A} is in another branch. So we must generate this
    set and test it. More generally we must test all cardinality-1 subsets
    which do not include the first element. This is done using the method 
    <TT>testCombinations</TT>. 
    </OL>
    <P>Example 2, given:
    <PRE>
    (A) ----- (D)
               |         
	       |         
	      (A) ----- (B) ----- (C)
	                           |
				   |
				  (A) ----- (B) 
    </PRE><P>	 
    where we wish to add a level 4 node (A) to (B) this would represent the
    complete label {D,C,B,A}, the N-1 subsets will then be {{D,C,B},{D,C,A},
    {D,B,A} and {C,B,A}}. We know the first two are supported becuase they are
    contained in the current sub-branch of the T-tree, {D,B,A} and {C,B,A} are
    not.
    </OL> 
    @param parentRef the reference to the level in the sub-branch of the T-tree
    under consideration.
    @param endIndex the index of the current node under consideration.
    @param itemSet the complete label represented by the current node (required
    to generate further itemsets to be X-checked). */
    
    protected void generateNextLevel(TtreeNode[] parentRef, int endIndex, 
    			short[] itemSet) {
	parentRef[endIndex].childRef = new TtreeNode[endIndex];	// New level
        short[] newItemSet;	
	// Generate a level in Ttree
	
	TtreeNode currentNode = parentRef[endIndex];
	
	// Loop through parent sub-level of siblings upto current node
	for (int index=1;index<endIndex;index++) {	
	    // Check if "uncle" element is supported (i.e. it exists) 
	    if (parentRef[index] != null) {	
		// Create an appropriate itemSet label to test
	        newItemSet = realloc2(itemSet,(short) index);
		if (testCombinations(newItemSet)) {
		    currentNode.childRef[index] = new TtreeNode();
		    nextLevelExists=true;
		    }
	        else currentNode.childRef[index] = null;
	        }
	    }
	}  
	
    /* TEST COMBINATIONS */
    
    /** Commences the process of testing whether the N-1 sized sub-sets of a 
    newly created T-tree node are supported elsewhere in the Ttree --- (a 
    process refered to as "X-Checking"). <P> Thus given a candidate large 
    itemsets whose size-1 subsets are contained (supported) in the current 
    branch of the T-tree, tests whether size-1 subsets contained in other 
    branches are supported. Proceed as follows:   
    <OL>
    <LI> Using current item set split this into two subsets:
    <P>itemSet1 = first two items in current item set
    <P>itemSet2 = remainder of items in current item set
    <LI> Calculate size-1 combinations in itemSet2
    <LI> For each combination from (2) append to itemSet1 
    </OL>
    <P>Example 1: 
    <PRE>
    currentItemSet = {A,B,C} 
    itemSet1 = {B,A} (change of ordering)
    size = {A,B,C}-2 = 1
    itemSet2 = {C} (currentItemSet with first two elements removed)
    calculate combinations between {B,A} and {C}
    </PRE>
    <P>Example 2: 
    <PRE>
    currentItemSet = {A,B,C,D} 
    itemSet1 = {B,A} (change of ordering)
    itemSet2 = {C,D} (currentItemSet with first two elements removed)
    calculate combinations between {B,A} and {C,D}
    </PRE>
    @param currentItemSet the given itemset.		*/
    
    protected boolean testCombinations(short[] currentItemSet) {  

        if (currentItemSet.length < 3) return(true);
	   
	// Creat itemSet1 (note ordering)
	
	short[] itemSet1 = new short[2];
	itemSet1[0] = currentItemSet[1];
	itemSet1[1] = currentItemSet[0];
	
	// Creat itemSet2
	
	int size = currentItemSet.length-2;
	short[] itemSet2 = removeFirstNelements(currentItemSet,2);
	
	// Calculate combinations

	return(combinations(null,0,2,itemSet1,itemSet2));
	}
	
    /* COMBINATIONS */
    
    /** Determines the cardinality N combinations of a given itemset and then
    checks whether those combinations are supported in the T-tree. <P> 
    Operates in a recursive manner.
    <P>Example 1: Given --- sofarSet=null, 
    startIndex=0, endIndex=2, itemSet1 = {B,A} and itemSet2 = {C}
    <PRE>
    itemSet2.length = 1
    endIndex = 2 greater than itemSet2.length if condition succeeds
    tesSet = null+{B,A} = {B,A}
    retutn true if {B,A} supported and null otherwise
    </PRE>
    <P>Example 2: Given --- sofarSet=null, 
    startIndex=0, endIndex=2, itemSet1 = {B,A} and itemSet2 = {C,D}
    <PRE>
    endindex not greater than length {C,D}
    go into loop
    tempSet = {} + {C} = {C}
    	combinations with --- sofarSet={C}, startIndex=1, 
			endIndex=3, itemSet1 = {B,A} and itemSet2 = {C}
	endIndex greater than length {C,D}
	testSet = {C} + {B,A} = {C,B,A}
    tempSet = {} + {D} = {D}
    	combinations with --- sofarSet={D}, startIndex=1, 
			endIndex=3, itemSet1 = {B,A} and itemSet2 = {C}
	endIndex greater than length {C,D}
	testSet = {D} + {B,A} = {D,B,A}
    </PRE>
    @param sofarSet The combination itemset generated so far (set to null at
    start)
    @param startIndex the current index in the given itemSet2 (set to 0 at 
    start).
    @param endIndex The current index of the given itemset (set to 2 at start)
    and incremented on each recursion until it is greater than the length of
    itemset2.
    @param itemSet1 The first two elements (reversed) of the totla label for the
    current item set.
    @param itemSet2 The remainder of the current item set.
    */	
	
    private boolean combinations(short[] sofarSet, int startIndex,
    		    int endIndex, short[] itemSet1, short[] itemSet2) {
	// At level
	
	if (endIndex > itemSet2.length) {
	    short[] testSet = append(sofarSet,itemSet1);
	    // If testSet exists in the T-tree sofar then it is supported
	    return(findItemSetInTtree(testSet));
	    }
	
	// Otherwise
	else {
	    short[] tempSet;
	    for (int index=startIndex;index<endIndex;index++) {
	        tempSet = realloc2(sofarSet,itemSet2[index]);
	        if (!combinations(tempSet,index+1,endIndex+1,itemSet1,
				itemSet2)) return(false);
	        }
	    }						
        
	// Return
	
	return(true);
	}    
    	
    /*---------------------------------------------------------------------- */
    /*                                                                       */
    /*                        T-TREE SEARCH METHODS                          */
    /*                                                                       */
    /*---------------------------------------------------------------------- */  
    
    /* FIND ITEM SET IN T-TREE*/
    
    /** Commences process of determining if an itemset exists in a T-tree. <P> 
    Used to X-check existance of Ttree nodes when generating new levels of the 
    Tree. Note that T-tree node labels are stored in "reverse", e.g. {3,2,1}. 
    @param itemSet the given itemset (IN REVERSE ORDER). 
    @return returns true if itemset found and false otherwise. */
    
    private boolean findItemSetInTtree(short[] itemSet) {

    	// first element of itemset in Ttree (Note: Ttree itemsets stored in 
	// reverse)
  	if (startTtreeRef[itemSet[0]] != null) {
    	    int lastIndex = itemSet.length-1;
	    // If single item set return true
	    if (lastIndex == 0) return(true);
	    // Otherwise continue down branch
	    else return(findItemSetInTtree2(itemSet,1,lastIndex,
			startTtreeRef[itemSet[0]].childRef));
	    }	
	// Item set not in Ttree
    	else return(false);
	}
    
    /** Returns true if the given itemset is found in the T-tree and false 
    otherwise. <P> Operates recursively. 
    @param itemSet the given itemset. 
    @param index the current index in the given T-tree level (set to 1 at
    start).
    @param lastIndex the end index of the current T-tree level.
    @param linRef the reference to the current T-tree level. 
    @return returns true if itemset found and false otherwise. */
     
    private boolean findItemSetInTtree2(short[] itemSet, int index, 
    			int lastIndex, TtreeNode[] linkRef) {  

        // Element at "index" in item set exists in Ttree
  	if (linkRef[itemSet[index]] != null) {
  	    // If element at "index" is last element of item set then item set
	    // found
	    if (index == lastIndex) return(true);
	    // Otherwise continue
	    else return(findItemSetInTtree2(itemSet,index+1,lastIndex,
	    		linkRef[itemSet[index]].childRef));
	    }	
	// Item set not in Ttree
	else return(false);    
    	}
	
    /* ---------------------------------------------------------------- */
    /*                                                                  */
    /*                  GET MINIMUM SUPPORT VALUE                       */
    /*                                                                  */
    /* ---------------------------------------------------------------- */
    
    /* GET SUPPORT */
    
    private void addSupport() {
        try{
           while (true) {
               String stNum1 = JOptionPane.showInputDialog("Input minimum " +
	       		" support value between " + MIN_SUPPORT + " and " +
							MAX_SUPPORT);
	       if (stNum1.indexOf('.') > 0) 
	       			support = Double.parseDouble(stNum1);						
               else support = Integer.parseInt(stNum1);
               if (support>=MIN_SUPPORT && support<=MAX_SUPPORT) break;
               JOptionPane.showMessageDialog(null,
	       		"MINIMUM SUPPORT VALUE INPUT ERROR:\n" +
	       		"input = " + support +
	       		"\nminimum support input must be a floating point\n" +
			         "number between " + MIN_SUPPORT + " and " + 
							MAX_SUPPORT);
				 
	       }
	    textArea.append("Minimum support = " + support + "%\n");
	    hasSupportFlag=true;
	    }
        catch(NumberFormatException e) {
            hasSupportFlag=false;
	    runButton.setEnabled(false);
	    }
	    
        // Enable run button if have data and a minimum support value.
	if (haveDataFlag && hasSupportFlag) runButton.setEnabled(true);
	}
    
    /* ---------------------------------------------------------------- */
    /*                                                                  */
    /*                           OPEN NAME                              */
    /*                                                                  */
    /* ---------------------------------------------------------------- */
	    
    /* OPEN THE FILE */
    	
    private void getFileName() {
        // Display file dialog so user can select file to open
	JFileChooser fileChooser = new JFileChooser();
	fileChooser.setFileSelectionMode(JFileChooser.FILES_ONLY);	
	int result = fileChooser.showOpenDialog(this);
	
	// If cancel button selected return
	if (result == JFileChooser.CANCEL_OPTION) return;
	
	// Obtain selected file	
	fileName = fileChooser.getSelectedFile();
	// Read file if readabale (i.e not a direcrory etc.).
	if (checkFileName()) {
	    readFile();
	    }
	
	// Check ordering		
	if (inputFormatOkFlag) {
	    if (checkOrdering()) {
	        // Enable run button if have data and a minimum support value.
	        if (haveDataFlag && hasSupportFlag) runButton.setEnabled(true);
	        // Output to text area
	        outputDataArray();
		textArea.append("Number of records = " + numRows + "\n");
		countNumCols();
		textArea.append("Number of columns = " + numCols + "\n");
		}
	    else {
	        haveDataFlag = false;
	        inputFormatOkFlag = true;
	        textArea.append("Error reading file: " + fileName + "\n\n");		
	        runButton.setEnabled(false);
	        }
	    }
	}	    
    		 
    /* CHECK FILE NAME */
	
    /* Return flase if selected file is a directory, access is denied or is
    not a file name. */
	
    private boolean checkFileName() {
	if (fileName.exists()) {
	    if (fileName.canRead()) {
		if (fileName.isFile()) return(true);
		else JOptionPane.showMessageDialog(null,
				"FILE ERROR: File is a directory");
		}
	    else JOptionPane.showMessageDialog(null,
	    			"FILE ERROR: Access denied");   
	    } 
	else JOptionPane.showMessageDialog(null,
				"FILE ERROR: No such file!"); 
	// Return
	
	return(false);
	}

    /* READ FILE */
    
    private void readFile() {
	
	try {
	    // Dimension data structure
	    inputFormatOkFlag=true;
	    getNumberOfLines();
	    if (inputFormatOkFlag) {
	        dataArray = new short[numRows][];	
	        // Read file
	        inputDataSet();	
  	        // Set have data flag to true
	        haveDataFlag = true;
		}
	    else {
	        haveDataFlag = false;
		textArea.append("Error reading file: " + fileName + "\n\n");		
		runButton.setEnabled(false);
		}	
	    }
	catch(IOException ioException) {
	    JOptionPane.showMessageDialog(this,"Error reading File", 
			 "Error 5: ",JOptionPane.ERROR_MESSAGE); 
	    closeFile();
	    System.exit(1);
	    }	    
	}
	
    /* GET NUMBER OF LINES */
    
    /** Gets number of lines in file and prepares data structure. */
    
    private void getNumberOfLines() throws IOException {
        int counter = 0;
	
	// Open the file
	openFile();
	
	// Loop through file incrementing counter
	// get first row.
	String line = fileInput.readLine();	
	while (line != null) {
	    checkLine(counter+1,line);
	    StringTokenizer dataLine = new StringTokenizer(line);
            int numberOfTokens = dataLine.countTokens();
	    if (numberOfTokens == 0) break;
	    counter++;	 
            line = fileInput.readLine();
	    }
	
	numRows = counter;
        closeFile();
	}

    /* CHECK LINE */
    
    /** Check whether input file is of appropriate numeric input. */	
    
    private void checkLine(int counter, String str) {
    
        for (int index=0;index <str.length();index++) {
            if (!Character.isDigit(str.charAt(index)) &&
	    			!Character.isWhitespace(str.charAt(index))) {
                JOptionPane.showMessageDialog(null,"FILE INPUT ERROR:\ncharcater " +
		       "on line " + counter + " is not a digit or white space");
	        inputFormatOkFlag = false;
		break;
		}
	    }
	}
    
    /* INPUT DATA SET */
    
    /** Reads input data from file specified in command line argument. */
    
    public void inputDataSet() throws IOException {  
        int rowIndex=0;
	textArea.append("Reading input file\n" + fileName + "\n");
	
	// Open the file
	openFile();
	
	// get first row.
	String line = fileInput.readLine();	
	while (line != null) {
	    StringTokenizer dataLine = new StringTokenizer(line);
            int numberOfTokens = dataLine.countTokens();
	    if (numberOfTokens == 0) break;
	    // Convert input string to a sequence of short integers
	    short[] code = binConversion(dataLine,numberOfTokens);
	    // Check for "null" input
	    if (code != null) {
	        // Dimension row in 2-D dataArray
		int codeLength = code.length;
		dataArray[rowIndex] = new short[codeLength];
		// Assign to elements in row
		for (int colIndex=0;colIndex<codeLength;colIndex++)
				dataArray[rowIndex][colIndex] = code[colIndex];
		}
	    else dataArray[rowIndex]= null;
	    // Increment first index in 2-D data array
	    rowIndex++;
	    // get next line
            line = fileInput.readLine();
	    }
	
	// Close file
	closeFile();
	}
	
    /* BINARY CONVERSION. */
    
    /** Produce an item set (array of elements) from input 
    line. 
    @param dataLine row from the input data file
    @param numberOfTokens number of items in row
    @return 1-D array of short integers representing attributes in input
    row */
    
    private short[] binConversion(StringTokenizer dataLine, 
    				int numberOfTokens) {
        short number;
	short[] newItemSet = null;
	
	// Load array
	
	for (int tokenCounter=0;tokenCounter < numberOfTokens;tokenCounter++) {
            number = new Short(dataLine.nextToken()).shortValue();
	    newItemSet = realloc1(newItemSet,number);
	    }
	
	// Return itemSet	
	
	return(newItemSet);
	}  

    /* CHECK DATASET ORDERING */
    
    /** Checks that data set is ordered correctly. */
    
    private boolean checkOrdering() {
        boolean result = true; 
	
	// Loop through input data
	for(int index=0;index<dataArray.length;index++) {
	    if (!checkLineOrdering(index+1,dataArray[index])) result=false;
	    }
	    
	// Return 
	return(result);
	}
    
    private boolean checkLineOrdering(int lineNum, short[] itemSet) {
        for (int index=0;index<itemSet.length-1;index++) {
	    if (itemSet[index] >= itemSet[index+1]) {
	        JOptionPane.showMessageDialog(null,"FILE FORMAT ERROR:\n" +
	       		"Attribute data in line " + lineNum + 
			" not in numeric order");
		return(false);
		}
	    }    
	
	// Default return
	return(true);
	}
	
    /* COUNT NUMBER OF COLUMNS */	
    private void countNumCols() {
        int maxAttribute=0;
	
	// Loop through data array	
        for(int index=0;index<dataArray.length;index++) {
	    int lastIndex = dataArray[index].length-1;
	    if (dataArray[index][lastIndex] > maxAttribute)
	    		maxAttribute = dataArray[index][lastIndex];	    
	    }
	
	numCols = maxAttribute;
	}
	
    /* ------------------------------------------------- */
    /*                                                   */
    /*                   OUTPUT METHODS                  */
    /*                                                   */
    /* ------------------------------------------------- */
    	
    /* OUTPUT DATA TABLE */
    
    /** Outputs stored input data set; initially read from input data file, but
    may be reirdered or pruned if desired by a particular application. */
     
    public void outputDataArray() {
        for(int index=0;index<dataArray.length;index++) {
	    outputItemSet(dataArray[index]);
	    textArea.append("\n");
	    }
	}
    
    /* OUTPUT ITEMSET */
    
    /** Outputs a given item set. 
    @param itemSet the given item set. */
    
    protected void outputItemSet(short[] itemSet) {
	String itemSetStr = " {";
	    
	// Loop through item set elements
	
	int counter = 0;
	for (int index=0;index<itemSet.length;index++) {
	    if (counter != 0) itemSetStr = itemSetStr + ",";
	    counter++;
	    itemSetStr = itemSetStr + itemSet[index];
	    }
	
	textArea.append(itemSetStr + "}");
	}

    /* OUTPUT FREQUENT SETS */
    
    /** Commences the process of outputting the frequent sets contained in 
    the T-tree. */	
    
    public void outputFrequentSets() {
	int number = 1;
	
	textArea.append("FREQUENT (LARGE) ITEM SETS (with support counts)\n" +
			"------------------------------------------------\n");
	
	// Loop
	
	short[] itemSetSofar = new short[1];
	for (int index=1; index <= numCols; index++) {
	    if (startTtreeRef[index] !=null) {
	        if (startTtreeRef[index].support >= minSupportRows) {
	            textArea.append("[" + number + "]  {" + index + "} = " + 
		    			startTtreeRef[index].support + "\n");
	            itemSetSofar[0] = (short) index;
		    number = outputFrequentSets(number+1,itemSetSofar,
		    			index,startTtreeRef[index].childRef);
		    }
		}
	    }    
	
	// End
	
	textArea.append("\n");
	}

    /** Outputs T-tree frequent sets. <P> Operates in a recursive manner.
    @param number the number of frequent sets so far.
    @param itemSetSofar the label for a T-treenode as generated sofar.
    @param size the length/size of the current array lavel in the T-tree.
    @param linkRef the reference to the current array lavel in the T-tree. 
    @return the incremented (possibly) number the number of frequent sets so 
    far. */
    
    private int outputFrequentSets(int number, short[] itemSetSofar, int size,
    							TtreeNode[] linkRef) {
	
	// No more nodes
	
	if (linkRef == null) return(number);
	
	// Otherwise process
	
	for (int index=1; index < size; index++) {
	    if (linkRef[index] != null) {
	        if (linkRef[index].support >= minSupportRows) {
		    short[] newItemSetSofar = realloc2(itemSetSofar,
		    				(short) index);
	            textArea.append("[" + number + "] ");
		    outputItemSet(newItemSetSofar); 
		    textArea.append(" = " + linkRef[index].support + "\n");	            
	            number = outputFrequentSets(number + 1,newItemSetSofar,
		    			index,linkRef[index].childRef); 
	            }
		}
	    }    
	
	// Return
	
	return(number);
	}    
			  
    /* ------------------------------------------------------- */
    /*                                                         */
    /*                  FILE HANDLING UTILITIES                */
    /*                                                         */
    /* ------------------------------------------------------- */
	
    /* OPEN FILE */
    
    private void openFile() {
	try {
	    // Open file
	    FileReader file = new FileReader(fileName);
	    fileInput = new BufferedReader(file);
	    }
	catch(IOException ioException) {
	    JOptionPane.showMessageDialog(this,"Error Opening File", 
			 "Error 4: ",JOptionPane.ERROR_MESSAGE);
	    }
	}
	   
    /* CLOSE FILE */
    
    private void closeFile() {
        if (fileInput != null) {
	    try {
	    	fileInput.close();
		}
	    catch (IOException ioException) {
	        JOptionPane.showMessageDialog(this,"Error Opening File", 
			 "Error 4: ",JOptionPane.ERROR_MESSAGE);
	        }
	    }
	}
	  
    /* ------------------------------------------------------- */
    /*                                                         */
    /*                       ARM UTILITIES                     */
    /*                                                         */
    /* ------------------------------------------------------- */	
    /* REALLOC 1 */
    
    /** Resizes given item set so that its length is increased by one
    and append new element
    @param oldItemSet the original item set
    @param newElement the new element/attribute to be appended
    @return the combined item set */
    
    protected short[] realloc1(short[] oldItemSet, short newElement) {
        
	// No old item set
	
	if (oldItemSet == null) {
	    short[] newItemSet = {newElement};
	    return(newItemSet);
	    }
	
	// Otherwise create new item set with length one greater than old 
	// item set
	
	int oldItemSetLength = oldItemSet.length;
	short[] newItemSet = new short[oldItemSetLength+1];
	
	// Loop
	
	int index;
	for (index=0;index < oldItemSetLength;index++)
		newItemSet[index] = oldItemSet[index];
	newItemSet[index] = newElement;
	
	// Return new item set
	
	return(newItemSet);
	}	

    /* APPEND */
    
    /** Concatinates two itemSets --- resizes given array so that its 
    length is increased by size of second array and second array added. 
    @param itemSet1 The first item set.
    @param itemSet2 The item set to be appended. 
    @return the combined item set */

    protected short[] append(short[] itemSet1, short[] itemSet2) {
        
	// Test for emty sets, if found return other
	
	if (itemSet1 == null) return(copyItemSet(itemSet2));
	else if (itemSet2 == null) return(copyItemSet(itemSet1));
        
	// Create new array
	
	short[] newItemSet = new short[itemSet1.length+itemSet2.length];
	
	// Loop through itemSet 1
	
	int index1;
	for(index1=0;index1<itemSet1.length;index1++) {
	    newItemSet[index1]=itemSet1[index1];
	    }
	
	// Loop through itemSet 2
	
	for(int index2=0;index2<itemSet2.length;index2++) {
	    newItemSet[index1+index2]=itemSet2[index2];
	    }

	// Return
	
	return(newItemSet);	
        }
	
    /* REALLOC 2 */
    
    /** Resizes given array so that its length is increased by one element
    and new element added to front
    @param oldItemSet the original item set
    @param newElement the new element/attribute to be appended
    @return the combined item set */
    
    protected short[] realloc2(short[] oldItemSet, short newElement) {
        
	// No old array
	
	if (oldItemSet == null) {
	    short[] newItemSet = {newElement};
	    return(newItemSet);
	    }
	
	// Otherwise create new array with length one greater than old array
	
	int oldItemSetLength = oldItemSet.length;
	short[] newItemSet = new short[oldItemSetLength+1];
	
	// Loop
	
	newItemSet[0] = newElement;
	for (int index=0;index < oldItemSetLength;index++)
		newItemSet[index+1] = oldItemSet[index];
	
	// Return new array
	
	return(newItemSet);
	}
    
    /* REMOVE FIRST N ELEMENTS */
    
    /** Removes the first n elements/attributes from the given item set.
    @param oldItemSet the given item set.
    @param n the number of leading elements to be removed. 
    @return Revised item set with first n elements removed. */
    
    protected short[] removeFirstNelements(short[] oldItemSet, int n) {
        if (oldItemSet.length == n) return(null);
    	else {
	    short[] newItemSet = new short[oldItemSet.length-n];
	    for (int index=0;index<newItemSet.length;index++) {
	        newItemSet[index] = oldItemSet[index+n];
	        }
	    return(newItemSet);
	    }
	}

     /* COPY ITEM SET */
    
    /** Makes a copy of a given itemSet. 
    @param itemSet the given item set.
    @return copy of given item set. */
    
    protected short[] copyItemSet(short[] itemSet) {
	
	// Check whether there is a itemSet to copy
	
	if (itemSet == null) return(null);
	
	// Do copy and return
	
	short[] newItemSet = new short[itemSet.length];
	for(int index=0;index<itemSet.length;index++) {
	    newItemSet[index] = itemSet[index];
	    }
        return(newItemSet);
	}
	
    /* ------------------------------------------------------- */
    /*                                                         */
    /*                         MAIN METHOD                     */
    /*                                                         */
    /* ------------------------------------------------------- */
    	
    /* MAIN METHOD */
    
    public static void main(String[] args) throws IOException {
	// Create instance of class AprioriTgui
	AprioriTgui newFile = new AprioriTgui("LUCS-KDD Apriori-T");
        
	// Make window vissible
	newFile.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	newFile.setSize(500,800);
        newFile.setVisible(true);
        }
    }
