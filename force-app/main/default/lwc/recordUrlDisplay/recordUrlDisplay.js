import { LightningElement, wire, api } from "lwc";
import getUrls from "@salesforce/apex/RecordUrlDisplay.getUrls";
import ug_Render_URL from "@salesforce/label/c.ug_Render_URL";

export default class recordUrlDisplay extends LightningElement {
	
	@api recordId = "001N000001vzLWx";
	@api communityName;
	@api types = "jpg,png,bmp";
	@api title = "Images";
	
	imageTypes;
	loading;
	SIZE = [
		{
			label: "Original",
			value: "ORIGINAL"
		}, {
			label: "Medium",
			value: "THUMB720BY480"
		}, {
			label: "Thumbnail",
			value: "THUMB240BY180"
		}, {
			label: "Icon",
			value: "THUMB120BY90"
		}
	];
	selectedSize = this.SIZE[0].value;
	@wire(getUrls, {
		recordId: "$recordId",
		contentTypes: "$imageTypes"
	}) files;
	
	get sizeValues() {
		return this.SIZE;
	}
	
	/**
	 * Prepare a list of image names and parameters.
	 * @returns {[]}
	 */
	get urlsForSelectedSize() {
		let values = [];
		this.loading = false;
		if (this.files && this.files.data) {
			this.files.data.forEach(file => {
				let communityName = this.communityName ? "/" + this.communityName : "";
				
				// Prepare the format for original i.e Original_<Filetype>. Special case.
				
				let size = this.selectedSize === this.SIZE[0].value ?
					`${this.selectedSize}_${file.FileExtension}` : this.selectedSize;
				
				let version = file.ContentVersions[0].Id;
				
				let uri = decodeURI(ug_Render_URL).replace("COMMUNITY_API_NAME", communityName)
					.replace("SIZE", size)
					.replace("VERSION_ID", version)
					.replace("&amp;", "&");
				
				values.push({
					id: file.Id,
					name: file.Title,
					fileType: file.FileType,
					url: uri
				});
			});
		}
		return values;
	}
	
	connectedCallback() {
		this.loading = true;
		this.imageTypes = this.types.split(",");
	}
	
	handleSizeChange(e) {
		this.selectedSize = e.target.value;
	}
	
}