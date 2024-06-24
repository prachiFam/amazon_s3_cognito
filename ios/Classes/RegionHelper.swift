//
//  RegionHelper.swift
//  amazon_s3_cognito
//
//  Created by Paras mac on 11/10/21.
//

import Foundation
import AWSS3

class RegionHelper{
    
    public static func getRegion( name:String ) -> AWSRegionType{

        if(name == "US_EAST_1"){
            return AWSRegionType.USEast1
        }else if(name == "AP_SOUTHEAST_1"){
            return AWSRegionType.APSoutheast1
        }else if(name == "US_EAST_2"){
            return AWSRegionType.USEast2
        }else if(name == "EU_WEST_1"){
            return AWSRegionType.EUWest1
        }else if(name == "CA_CENTRAL_1"){
            return AWSRegionType.CACentral1
        }else if(name == "CN_NORTH_1"){
            return AWSRegionType.CNNorth1
        } else if(name == "CN_NORTHWEST_1"){
            return AWSRegionType.CNNorthWest1
        }else if(name == "EU_CENTRAL_1"){
            return AWSRegionType.EUCentral1
        } else if(name == "EU_WEST_2"){
            return AWSRegionType.EUWest2
        }else if(name == "EU_WEST_3"){
            return AWSRegionType.EUWest3
        } else if(name == "SA_EAST_1"){
            return AWSRegionType.SAEast1
        } else if(name == "US_WEST_1"){
            return AWSRegionType.USWest1
        }else if(name == "US_WEST_2"){
            return AWSRegionType.USWest2
        } else if(name == "AP_NORTHEAST_1"){
            return AWSRegionType.APNortheast1
        } else if(name == "AP_NORTHEAST_2"){
            return AWSRegionType.APNortheast2
        } else if(name == "AP_SOUTHEAST_1"){
            return AWSRegionType.APSoutheast1
        }else if(name == "AP_SOUTHEAST_2"){
            return AWSRegionType.APSoutheast2
        } else if(name == "AP_SOUTH_1"){
            return AWSRegionType.APSouth1
        }else if(name == "ME_SOUTH_1"){
          return AWSRegionType.MESouth1
        }

        return AWSRegionType.Unknown

    }
}
