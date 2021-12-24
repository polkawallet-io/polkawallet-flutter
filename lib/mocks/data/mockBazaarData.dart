import 'package:encointer_wallet/store/encointer/types/bazaar.dart';
import 'package:encointer_wallet/store/encointer/types/communities.dart';

const String controller1 = '0x1cc4e46bbd2bb547d93d952c5de12ea7e3a3f3b638551a8eaf35ad086700c00c';
const String controller2 = '0x2cc4e46bbd2bb547d93d952c5de12ea7e3a3f3b638551a8eaf35ad086700c00c';
const String controller3 = '0x3cc4e46bbd2bb547d93d952c5de12ea7e3a3f3b638551a8eaf35ad086700c00c';

const String business_ipfs_cid1 = '0x1ebf164a5bb618ec6caad31488161b237e24d75efa3040286767b620d9183989';
const String business_ipfs_cid2 = '0x2ebf164a5bb618ec6caad31488161b237e24d75efa3040286767b620d9183989';
const String business_ipfs_cid3 = '0x3ebf164a5bb618ec6caad31488161b237e24d75efa3040286767b620d9183989';

final CommunityIdentifier cid1 = CommunityIdentifier.fromFmtString("gbsuv7YXq9G");
final CommunityIdentifier cid2 = CommunityIdentifier.fromFmtString("fbsuv7YXq9G");

final BusinessIdentifier bid1 = BusinessIdentifier(cid1, controller1);
final BusinessIdentifier bid2 = BusinessIdentifier(cid1, controller2);
final BusinessIdentifier bid3 = BusinessIdentifier(cid1, controller3);

final List<AccountBusinessTuple> allMockBusinesses = [
  AccountBusinessTuple(controller1, BusinessData(business_ipfs_cid1, 1)),
  AccountBusinessTuple(controller2, BusinessData(business_ipfs_cid2, 1)),
  AccountBusinessTuple(controller3, BusinessData(business_ipfs_cid3, 1)),
];

const String offering_ipfs_cid1 = '0x67ebf164a5bb618ec6caad31488161b237e24d75efa3040286767b620d9183989';
const String offering_ipfs_cid2 = '0x77ebf164a5bb618ec6caad31488161b237e24d75efa3040286767b620d9183989';
const String offering_ipfs_cid3 = '0x87ebf164a5bb618ec6caad31488161b237e24d75efa3040286767b620d9183989';
const String offering_ipfs_cid4 = '0x97ebf164a5bb618ec6caad31488161b237e24d75efa3040286767b620d9183989';

final OfferingData offeringData1 = OfferingData(offering_ipfs_cid1);
final OfferingData offeringData2 = OfferingData(offering_ipfs_cid2);
final OfferingData offeringData3 = OfferingData(offering_ipfs_cid3);
final OfferingData offeringData4 = OfferingData(offering_ipfs_cid4);

final Map<BusinessIdentifier, List<OfferingData>> offeringsForBusiness = {
  bid1: business1MockOfferings,
  bid2: business2MockOfferings,
  bid3: [],
};

final List<OfferingData> business1MockOfferings = [
  offeringData1,
  offeringData2,
];

final List<OfferingData> business2MockOfferings = [
  offeringData3,
  offeringData4,
];

final List<OfferingData> allMockOfferings = [
  offeringData1,
  offeringData2,
  offeringData3,
  offeringData4,
];

final List<IpfsBusiness> allMockIpfsBusinesses = [
  ipfsBusiness1,
  ipfsBusiness2,
  ipfsBusiness3,
];

final Map<String, IpfsOffering> ipfsOfferings = {
  offering_ipfs_cid1: ipfsOffering1,
  offering_ipfs_cid2: ipfsOffering2,
  offering_ipfs_cid3: ipfsOffering3,
  offering_ipfs_cid4: ipfsOffering4,
};

final Map<String, IpfsBusiness> ipfsBusinesses = {
  business_ipfs_cid1: ipfsBusiness1,
  business_ipfs_cid2: ipfsBusiness2,
  business_ipfs_cid3: ipfsBusiness3,
};

// Todo: @armin add some actual images to assets that look nice in the bazaar.
// Additionally, the bazaar should support more than one image per asset/business.
final ipfsBusiness1 = IpfsBusiness("Homemade delicacies", "Everything is yummy", "Бишкек, Ala Too Square",
    "assets/images/assets/Assets_nav_0.png", "Mo-Thu, 8am-8pm");
final ipfsBusiness2 = IpfsBusiness("From Malfoy for Dumbledore", "You will love it", "Zürich, Technoparkstrasse 1",
    "assets/images/assets/Assets_nav_0.png", "Mo-Thu, 8am-8pm");
final ipfsBusiness3 = IpfsBusiness(
    "NFT plaza", "Everything is yummy", "Miami Beach", "assets/images/assets/Assets_nav_0.png", "Mo-Thu, 8am-8pm");

final ipfsOffering1 =
    IpfsOffering("Cheesecake", 1, "I am yummy", "Бишкек, Ala Too Square", "assets/images/assets/Assets_nav_0.png");
final ipfsOffering2 =
    IpfsOffering("шашлы́к", 1, "I am yummy", "Бишкек, Ala Too Square", "assets/images/assets/Assets_nav_0.png");
final ipfsOffering3 = IpfsOffering("Harry Potter Heptalogy", 1, "I am interesting", "Zürich, Technoparkstrasse 1",
    "assets/images/assets/Assets_nav_0.png");
final ipfsOffering4 = IpfsOffering(
    "Picasso Fake as NFT by C.L.", 1, "I am beautiful", "Miami Beach", "assets/images/assets/Assets_nav_0.png");
