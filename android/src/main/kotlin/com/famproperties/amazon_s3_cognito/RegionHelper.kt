package com.famproperties.amazon_s3_cognito

import com.amazonaws.regions.Regions

class RegionHelper(regionAsPerPlugin: String) {


    private var regionName:Regions

    init {
        this.regionName = getRegionFor(regionAsPerPlugin)
    }

    public fun getRegionName():Regions{
        return regionName
    }
    private fun  getRegionFor(name:String): Regions {

        if(name == "US_EAST_1"){
            return Regions.US_EAST_1
        }else if(name == "AP_SOUTHEAST_1"){
            return Regions.AP_SOUTHEAST_1
        }else if(name == "US_EAST_2"){
            return Regions.US_EAST_2
        }else if(name == "EU_WEST_1"){
            return Regions.EU_WEST_1
        }else if(name == "CA_CENTRAL_1"){
            return Regions.CA_CENTRAL_1
        }else if(name == "CN_NORTH_1"){
            return Regions.CN_NORTH_1
        } else if(name == "CN_NORTHWEST_1"){
            return Regions.CN_NORTHWEST_1
        }else if(name == "EU_CENTRAL_1"){
            return Regions.EU_CENTRAL_1
        } else if(name == "EU_WEST_2"){
            return Regions.EU_WEST_2
        }else if(name == "EU_WEST_3"){
            return Regions.EU_WEST_3
        } else if(name == "SA_EAST_1"){
            return Regions.SA_EAST_1
        } else if(name == "US_WEST_1"){
            return Regions.US_WEST_1
        }else if(name == "US_WEST_2"){
            return Regions.US_WEST_2
        } else if(name == "AP_NORTHEAST_1"){
            return Regions.AP_NORTHEAST_1
        } else if(name == "AP_NORTHEAST_2"){
            return Regions.AP_NORTHEAST_2
        } else if(name == "AP_SOUTHEAST_1"){
            return Regions.AP_SOUTHEAST_1
        }else if(name == "AP_SOUTHEAST_2"){
            return Regions.AP_SOUTHEAST_2
        } else if(name == "AP_SOUTH_1"){
            return Regions.AP_SOUTH_1
        }else if(name == "ME_SOUTH_1"){
            return Regions.ME_SOUTH_1
        }else if(name == "AP_EAST_1"){
            return Regions.AP_EAST_1
        }else if(name == "EU_NORTH_1"){
            return Regions.EU_NORTH_1
        }else if(name == "US_GOV_EAST_1"){
            return Regions.US_GOV_EAST_1
        }else if(name == "us-gov-west-1"){
            return Regions.GovCloud
        }

        return Regions.DEFAULT_REGION

    }
}