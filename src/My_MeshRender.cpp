/*******************************************************************************
Joshua Powers made this file for Voxelyze.jl wrapper around Voxelyze
*******************************************************************************/

#include "My_MeshRender.h"
#include "VX_Voxel.h"

#include <iostream>
#include <fstream>

//link direction to clockwise vertex lookup info:
CVX_Voxel::voxelCorner CwLookup[6][4] = {
	{CVX_Voxel::PNN, CVX_Voxel::PPN, CVX_Voxel::PPP, CVX_Voxel::PNP}, //linkDirection::X_POS
	{CVX_Voxel::NNN, CVX_Voxel::NNP, CVX_Voxel::NPP, CVX_Voxel::NPN}, //linkDirection::X_NEG
	{CVX_Voxel::NPN, CVX_Voxel::NPP, CVX_Voxel::PPP, CVX_Voxel::PPN}, //linkDirection::Y_POS
	{CVX_Voxel::NNN, CVX_Voxel::PNN, CVX_Voxel::PNP, CVX_Voxel::NNP}, //linkDirection::Y_NEG
	{CVX_Voxel::NNP, CVX_Voxel::PNP, CVX_Voxel::PPP, CVX_Voxel::NPP}, //linkDirection::Z_POS
	{CVX_Voxel::NNN, CVX_Voxel::NPN, CVX_Voxel::PPN, CVX_Voxel::PNN}  //linkDirection::Z_NEG
};

CVX_MeshRender::CVX_MeshRender(CVoxelyze* voxelyzeInstance)
{
	vx = voxelyzeInstance;
	generateMesh();
}

void CVX_MeshRender::generateMesh()
{
	vertices.clear();
	colors.clear();
	triangles.clear();
	int count = 1;
	
	int vCount = vx->voxelCount();
	for (int k=0; k<vCount; k++) //for each possible voxel location: (fill in vertices)
	{
		CVX_Voxel* pV = vx->voxel(k);
		if (pV->isInterior()) continue;

		for (int i=0; i<6; i++) //for each direction that a face could exist
		{
			if (pV->adjacentVoxel((CVX_Voxel::linkDirection)i)) continue;

			int idx[4];
			for (int j=0; j<4; j++) //for each corner of the (exposed) face in this direction
			{
				CVX_Voxel::voxelCorner corner = CwLookup[i][j];
				
				vertices.push_back(pV->cornerPosition(corner).x);
				vertices.push_back(pV->cornerPosition(corner).y);
				vertices.push_back(pV->cornerPosition(corner).z);

				colors.push_back(pV->material()->red()/255.0f);
				colors.push_back(pV->material()->green()/255.0f);
				colors.push_back(pV->material()->blue()/255.0f);
				colors.push_back(pV->material()->alpha()/255.0f);

				idx[j] = count;
				count += 1;
			}

			//first triangle of square face
			triangles.push_back(idx[0]);
			triangles.push_back(idx[1]);
			triangles.push_back(idx[2]);

			//second triangle of square face
			triangles.push_back(idx[2]);
			triangles.push_back(idx[3]);
			triangles.push_back(idx[0]);

		}
	}
}