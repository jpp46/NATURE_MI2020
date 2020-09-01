/*******************************************************************************
Copyright (c) 2015, Jonathan Hiller
To cite academic use of Voxelyze: Jonathan Hiller and Hod Lipson "Dynamic Simulation of Soft Multimaterial 3D-Printed Objects" Soft Robotics. March 2014, 1(1): 88-101.
Available at http://online.liebertpub.com/doi/pdfplus/10.1089/soro.2013.0010

This file is part of Voxelyze.
Voxelyze is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
Voxelyze is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
See <http://www.opensource.org/licenses/lgpl-3.0.html> for license details.
*******************************************************************************/

#ifndef VX_MESH_H
#define VX_MESH_H

#include "Voxelyze.h"
#include <vector>

//! Voxelyze mesh visualizer
/*!
A simple way to generate a deformed mesh reflecting the current state of a voxelyze object. After constructing with a pointer to the desired voxelyze object the mesh is ready. If the state of the voxelyze object has changed or a different coloring is desired, simply call updateMesh(). If voxels are added or subtracted to the voxelyze object, generateMesh() must be called to regenerate the mesh before calling updateMesh or drawGl().

The mesh can be drawn in an initialized OpenGL window by defining USE_OPEN_GL in the preprocessor and calling glDraw from within the drawing loop. An obj mesh file can also be generated at any time.
*/
class CVX_MeshRender
{
public:
	//! Defines various ways of coloring the voxels in the 3D mesh
	enum viewColoring {
		MATERIAL, //!< Display the material color specified by its RGB values
		FAILURE, //!< Display the current failure status (red=failed, yellow=yielded, white=ok)
		STATE_INFO //!< Display a color coded "head map" of the specified CVoxelyze::stateInfoType (displacement, kinetic energy, etc.)
	};

	CVX_MeshRender(CVoxelyze* voxelyzeInstance); //!< Initializes this mesh visualization with the specified voxelyze instance. This voxelyze pointer must remain valid for the duration of this object. @param[in] voxelyzeInstance The voxelyze instance to link this mesh object to.
	void generateMesh(); //!< Generates (or regenerates) this mesh from the linked voxelyze object. This must be called whenever voxels are added or removed in the simulation.

	float* getVertices() {return vertices.data();};
	int vCount() {return vertices.size();};
	float* getColors() {return colors.data();};
	int cCount() {return colors.size();};
	int* getTriangles() {return triangles.data();};
	int tCount() {return triangles.size();};
	
private:
	CVoxelyze* vx;

	std::vector<float> vertices;
	std::vector<float> colors;
	std::vector<int> triangles;
};
#endif
