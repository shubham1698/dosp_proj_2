Project 2: Gossip and Push-Sum Algorithm Simulation
===================================================

Team Members:
-------------

-   **Shubham Manoj Singh**
-   **Manav Mishra**

What is Working:
----------------

-   **Gossip Algorithm**: Successfully implemented and tested across all topologies (Line, 3D, Imperfect 3D, and Full). The algorithm converges when each node has spread the rumor 10 times.
-   **Push-Sum Algorithm**: Implemented and tested for all topologies. The algorithm converges when the ratio of `s/w` remains stable over three consecutive rounds.
-   **Topology Generation**:
    -   **Line Topology**: Each node connects to its immediate neighbors.
    -   **3D Topology**: Nodes are placed in a 3D grid, with neighbors connected based on their position in the grid.
    -   **Imperfect 3D Topology**: Similar to the 3D topology but with additional random neighbors added.
    -   **Full Topology**: Every node is connected to all other nodes, maximizing communication.
-   **Convergence Tracking**: The system accurately tracks when all nodes have converged for both algorithms and outputs the time taken for convergence.

Largest Network Tested:
-----------------------

-   **Line Topology**:
    -   **Gossip**: Successfully tested with up to **3000 nodes**.
    -   **Push-Sum**: Tested with up to **3000 nodes**, but the convergence time was notably higher due to the sequential nature of communication.
-   **3D Topology**:
    -   **Gossip**: Managed up to **800 nodes** with efficient convergence times.
    -   **Push-Sum**: Successfully tested up to **800 nodes**, with performance comparable to gossip for smaller networks but increasing times for larger ones.
-   **Imperfect 3D Topology**:
    -   **Gossip**: Managed up to **800 nodes** with relatively quick convergence.
    -   **Push-Sum**: Tested with **800 nodes**, showing a linear increase in convergence time as the network size grew.
-   **Full Topology**:
    -   **Gossip**: Handled networks up to **3000 nodes** with the best performance across all topologies.
    -   **Push-Sum**: Tested with **3000 nodes**, showing the best performance due to the full connectivity between nodes.

### **System Limitations**:

For the largest network sizes, we were only able to test up to the stated limits due to **system resource constraints**. Larger networks required more computational resources than were available, leading to performance bottlenecks and memory limitations.
